#!/bin/bash

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

IM_HOME=/opt/IBM/IM
log_file=/tmp/log_provisioning.log

echo "Setting the hosts on file [/etc/hosts] for the topology."
echo "192.168.1.11 wl.company.com" > /etc/hosts
echo "192.168.1.10 db2.company.com" >> /etc/hosts

echo "################# START:: PRE-REQ Installation Manager ####################### "
echo "Installing libraries required by Installation Manager on RedHat "
echo "Reference: http://www-01.ibm.com/support/docview.wss?uid=swg21459143"

mount -o loop /my_drive/rhel-server-6.5-x86_64-dvd.iso /mnt
repo_file=/etc/yum.repos.d/server.repo
echo "[server]" > $repo_file
echo "name=server" >> $repo_file
echo "baseurl=file:///mnt" >> $repo_file
echo "enabled=1" >> $repo_file
yum clean all
rpm --import /mnt/*GPG*
yum install gtk2.i686 -y
yum install libXtst.i686 -y
yum install compat-libstdc++ -y

echo "################# END:: PRE-REQ Installation Manager ####################### "

echo "############### Starting the Installation ####################"

echo "CMD> [unzip /vagrant/binario_ihs/agent.installer.linux.gtk.x86_1.7.3000.20140521_1925.zip -d /tmp/IM_server]"
unzip /vagrant/binary/agent.installer.linux.gtk.x86_1.7.3000.20140521_1925.zip -d /tmp/IM_server

REPOSITORY_IM_DIR=/tmp/IM_server

echo "Installing binaries of Installation Manager..." | tee -a $log_file
    $REPOSITORY_IM_DIR/tools/imcl install com.ibm.cic.agent \
        -acceptLicense -installationDirectory $IM_HOME -repositories $REPOSITORY_IM_DIR \
        -showVerboseProgress -log /tmp/silent_im_install.log
		
cat /tmp/silent_im_install.log | tee -a $log_file

echo "Unzipping the binary of WebSphere Liberty profile v8.5.5"
echo "CMD> [unzip WAS_Liberty_Core_V8.5.5.zip -d /tmp/WAS_Liberty]"
unzip /vagrant/binary/WAS_Liberty_Core_V8.5.5.zip -d /tmp/WAS_Liberty

echo "Unzipping Java 7 binaries"
for line in /vagrant/binary/SDK_JAVA_TE_V7.0_*.zip
do
	echo "CMD> [unzip $line -d /tmp/java7]"
	unzip $line -d /tmp/java7 > /dev/null
done

echo "Installing WAS Liberty profile v8.5.5 and Java 7"
$IM_HOME/eclipse/tools/imcl -acceptLicense -showProgress input /vagrant/wl_response.xml -log /tmp/outputWL.log

cat /tmp/outputWL.log | tee -a $log_file

echo "Unzipping Worklight binaries"
unzip /vagrant/binary/WKLT_CSMR_ED_6.2_ZIP_IMR_WKLT_Svr.zip -d /tmp/WorklightServer

echo "Creating server1 for Worklight configuration ..." 
/opt/IBM/WebSphere/Liberty/bin/server create server1

echo "Installing Worklight.."
$IM_HOME/eclipse/tools/imcl input /vagrant/install-liberty-db2.xml -log /tmp/installwl.log -acceptLicense

echo "Configuring Worklight..."
JAVA_HOME=/opt/IBM/WebSphere/Liberty/java/java_1.7_64
export JAVA_HOME

echo "JAVA_HOME=[$JAVA_HOME]"

PATH_ANT=/opt/IBM/Worklight/tools/apache-ant-1.8.4/bin
ANT_FILE=/vagrant/configure-liberty-db2.xml
${PATH_ANT}/ant -f ${ANT_FILE} admdatabases
${PATH_ANT}/ant -f ${ANT_FILE} adminstall
${PATH_ANT}/ant -f ${ANT_FILE} databases
${PATH_ANT}/ant -f ${ANT_FILE} install

echo "################ END INSTALLATION ################"
