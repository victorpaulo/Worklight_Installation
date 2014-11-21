# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Vagrant.configure("2") do |config|
  
  # This sync parameter is because I have to mount redhat .iso image to install packages 
  # for IBM Installation Manager which is located on my local drive (host machine) on G: driver;
  config.vm.synced_folder "G:/", "/my_drive"
  
  
  config.vm.define "db2" do |db|
    db.vm.box = "redhat65"
	db.vm.host_name = "db2.company.com"
	db.vm.network "public_network", ip: "192.168.1.10"
	db.vm.provider :virtualbox do |vb|
		vb.name = "VM DB2 for WORKLIGHT"
		vb.gui = false
		vb.memory = 4096
		vb.cpus = 2
	end
	db.vm.provision :shell, :path => "install_db2.sh"

  end	

  config.vm.define "worklight" do |wlt|
    wlt.vm.box = "redhat65"
	wlt.vm.host_name = "wl.company.com"
	wlt.vm.network "forwarded_port", guest: 9080, host: 9080
	wlt.vm.network "forwarded_port", guest: 9443, host: 9443
	wlt.vm.network "public_network", ip: "192.168.1.11"
	wlt.vm.provider :virtualbox do |vb|
		vb.name = "WORKLIGHT 6.2"
		vb.gui = false
		vb.memory = 4096
		vb.cpus = 2
	end
	wlt.vm.provision :shell, :path => "install.sh"

  end
end
