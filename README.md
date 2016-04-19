# kickstart generator
Maintaining dozens of kickstart files is overkill. This architecture for this system is stolen from cobbler.
## Usage
#### Standard Use
Running the ks_generate.pl command will copy the correct files, and generate a ks.cfg, and create the ISO in the desired directory.
`kickstart generator requires the following options:
        --KS_NAME 
        --BACKUPGATEWAY 
        --BACKUPIP 
        --BACKUPNETMASK 
        --HOSTNAME 
        --IPADDRESS 
        --IPGATEWAY 
        --IPNETMASK 
`

Example Output.
`ks_generator.pl  --KS_NAME=rhel6-oracle --BACKUPGATEWAY=10.1.0.10 --BACKUPIP=10.1.0.215 --BACKUPNETMASK=255.255.255.0 --HOSTNAME=spiffy-oracle-host1 --IPADDRESS=10.100.100.15 --IPGATEWAY=10.100.100.64 --IPNETMASK=255.255.255.192
Found  /home/christophermotes/git/kickstart_generator/snippets/header.required
Found  /home/christophermotes/git/kickstart_generator/snippets/install.required
Found  /home/christophermotes/git/kickstart_generator/snippets/network.required
Found  /home/christophermotes/git/kickstart_generator/snippets/users.required
Found  /home/christophermotes/git/kickstart_generator/snippets/other.required
Found  /home/christophermotes/git/kickstart_generator/snippets/repos.required
Found  /home/christophermotes/git/kickstart_generator/snippets/packages.required
Found  /home/christophermotes/git/kickstart_generator/snippets/post.required
Found  /home/christophermotes/git/kickstart_generator/snippets/rhel6-oracle/disk.default
Found /net/christophermotes/.ks_generator/disk.000
Found /home/christophermotes/git/kickstart_generator/snippets/rhel6-oracle/post.000
I: -input-charset not specified, using utf-8 (detected in locale settings)
genisoimage 1.1.9 (Linux)
Scanning isolinux/
Excluded: isolinux/TRANS.TBL
Excluded by match: isolinux/boot.cat
<SNIP> more IOS create stuff
Writing:   Ending Padblock                         Start Block 17434
Done with: Ending Padblock                         Block(s)    150
Max brk space used 0
17584 extents written (34 MB)
`

#### Customization use
kickstart_generator customizes files based off snippet files. Currently nine snippet files exist 'header', 'install', 'network', 'users', 'other', 'disk', 'repos', 'packages', 'post' (see @snippets array). Each snippet may be a required or default (see below). Other snippets will append to the required and default snippets.
1. Files in the customization directories : "~/.ks_generator", and "$snippet_base_dir/$KS_NAME"(see @snipette_dir_names array), with the .[::digit::], append to any snippet, to customize the kickstart.
    * ex. ~christophermotes/.ks_generator/network.000 would append to the network.required snippet
    * ORDER IS IMPORANT - multiple extensions will be order by customization directory, then numeric value (like ls *)
    * WARNING: updating any files in $snippet_base_dir/$KS_NAME must  be done through source control.
* Required snippet files are in $snippet_base_dir (see this script for now. We need a formal decision on where this should land) with the .require extension.
    * The '\*.required' files in $snippets__dase_dir are always used for every build
    * they will be appended to but not overwritten.
    * WARNING: to updated a required file,  you must update source control
    * ORDER IS IMPORTANT when appending.
* Default files are required but exist in the customization search tree.
    * The first '\*.default' file found is used.
        * ex. ~christophermotes/.ks_generator/disk.default would replace ${install_dir}/snippets/rhel6-oracle/disk.default
    * WARNING: to update a .default file in a $KS_NAME directory you must update source control. Using your home directory is preferable for the updates.
    * Files meeting the customization standard 
        *e.g. ${install_dir}/snippets/rhel6-oracle/disk.000 will append to the  first disk.default file found
        * ORDER IS IMPORTANT - see section 1.
