Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 19E286B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 12:46:43 -0500 (EST)
Received: by pvc30 with SMTP id 30so340961pvc.14
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 09:46:40 -0800 (PST)
Date: Wed, 8 Dec 2010 10:46:33 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101208174633.GA2086@mgebm.net>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
 <20101207232000.GA5353@shaohui>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Content-Disposition: inline
In-Reply-To: <20101207232000.GA5353@shaohui>
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Cc: shaohui.zheng@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Shaohui,

I have had some success.  I had run into confusion on the memory hotplug wi=
th=20
which files to be using to online memory.  The latest patch sorted it out f=
or me
and I can now online disabled memory in new nodes.  I still cannot online a=
n offlined
cpu.  Of the 12 available thread, I have 8 activated on boot with the kerne=
l command line:

mem=3D8G numa=3Dpossible=3D12 maxcpus=3D8 cpu_hpe=3Don

I can offline a CPU just fine according to the kernel:
root@bert:/sys/devices/system/cpu# echo 7 > release
(dmesg)
[  911.494852] offline cpu 7.
[  911.694323] CPU 7 is now offline

But when I try and re-add it I get an error:
root@bert:/sys/devices/system/cpu# echo 0 > probe
(dmesg)
Dec  8 10:41:55 bert kernel: [ 1190.095051] ------------[ cut here ]-------=
-----
Dec  8 10:41:55 bert kernel: [ 1190.095056] WARNING: at fs/sysfs/dir.c:451 =
sysfs_add_one+0xce/0x180()
Dec  8 10:41:55 bert kernel: [ 1190.095057] Hardware name: System Product N=
ame
Dec  8 10:41:55 bert kernel: [ 1190.095058] sysfs: cannot create duplicate =
filename '/devices/system/cpu/cpu7'
Dec  8 10:41:55 bert kernel: [ 1190.095060] Modules linked in: nfs binfmt_m=
isc lockd fscache nfs_acl auth_rpcgss sunrpc snd_hda_codec_hdmi snd_hda_cod=
ec_realtek radeon snd_hda_intel snd_hda_codec snd_cmipci gameport snd_pcm t=
tm snd_opl3_lib drm_kms_helper snd_hwdep snd_mpu401_uart drm uvcvideo snd_s=
eq_midi snd_rawmidi snd_seq_midi_event snd_seq xhci_hcd snd_timer videodev =
snd_seq_device snd psmouse i7core_edac i2c_algo_bit edac_core joydev v4l1_c=
ompat shpchp snd_page_alloc v4l2_compat_ioctl32 soundcore hwmon_vid asus_at=
k0110 max6650 serio_raw hid_microsoft usbhid hid firewire_ohci firewire_cor=
e crc_itu_t ahci sky2 libahci
Dec  8 10:41:55 bert kernel: [ 1190.095088] Pid: 2369, comm: bash Tainted: =
G        W   2.6.37-rc5-numa-test+ #3
Dec  8 10:41:55 bert kernel: [ 1190.095089] Call Trace:
Dec  8 10:41:55 bert kernel: [ 1190.095094]  [<ffffffff8105eb1f>] warn_slow=
path_common+0x7f/0xc0
Dec  8 10:41:55 bert kernel: [ 1190.095096]  [<ffffffff8105ec16>] warn_slow=
path_fmt+0x46/0x50
Dec  8 10:41:55 bert kernel: [ 1190.095098]  [<ffffffff811cf77e>] sysfs_add=
_one+0xce/0x180
Dec  8 10:41:55 bert kernel: [ 1190.095100]  [<ffffffff811cf8b1>] create_di=
r+0x81/0xd0
Dec  8 10:41:55 bert kernel: [ 1190.095102]  [<ffffffff811cf97d>] sysfs_cre=
ate_dir+0x7d/0xd0
Dec  8 10:41:55 bert kernel: [ 1190.095106]  [<ffffffff815a2b3d>] ? sub_pre=
empt_count+0x9d/0xd0
Dec  8 10:41:55 bert kernel: [ 1190.095109]  [<ffffffff812c9ffd>] kobject_a=
dd_internal+0xbd/0x200
Dec  8 10:41:55 bert kernel: [ 1190.095111]  [<ffffffff812ca258>] kobject_a=
dd_varg+0x38/0x60
Dec  8 10:41:55 bert kernel: [ 1190.095113]  [<ffffffff812ca2d3>] kobject_i=
nit_and_add+0x53/0x70
Dec  8 10:41:55 bert kernel: [ 1190.095117]  [<ffffffff8139475f>] sysdev_re=
gister+0x6f/0xf0
Dec  8 10:41:55 bert kernel: [ 1190.095121]  [<ffffffff81598f38>] register_=
cpu_node+0x32/0x88
Dec  8 10:41:55 bert kernel: [ 1190.095123]  [<ffffffff8158207e>] arch_regi=
ster_cpu_node+0x3e/0x40
Dec  8 10:41:55 bert kernel: [ 1190.095127]  [<ffffffff8101220e>] arch_cpu_=
probe+0x10e/0x1f0
Dec  8 10:41:55 bert kernel: [ 1190.095129]  [<ffffffff813989d4>] cpu_probe=
_store+0x14/0x20
Dec  8 10:41:55 bert kernel: [ 1190.095131]  [<ffffffff81393ef0>] sysdev_cl=
ass_store+0x20/0x30
Dec  8 10:41:55 bert kernel: [ 1190.095133]  [<ffffffff811cd925>] sysfs_wri=
te_file+0xe5/0x170
Dec  8 10:41:55 bert kernel: [ 1190.095137]  [<ffffffff811624c8>] vfs_write=
+0xc8/0x190
Dec  8 10:41:55 bert kernel: [ 1190.095139]  [<ffffffff81162e61>] sys_write=
+0x51/0x90
Dec  8 10:41:55 bert kernel: [ 1190.095142]  [<ffffffff8100c142>] system_ca=
ll_fastpath+0x16/0x1b
Dec  8 10:41:55 bert kernel: [ 1190.095144] ---[ end trace f615c2a524d318ea=
 ]---
Dec  8 10:41:55 bert kernel: [ 1190.095149] Pid: 2369, comm: bash Tainted: =
G        W   2.6.37-rc5-numa-test+ #3
Dec  8 10:41:55 bert kernel: [ 1190.095150] Call Trace:
Dec  8 10:41:55 bert kernel: [ 1190.095152]  [<ffffffff812ca09b>] kobject_a=
dd_internal+0x15b/0x200
Dec  8 10:41:55 bert kernel: [ 1190.095154]  [<ffffffff812ca258>] kobject_a=
dd_varg+0x38/0x60
Dec  8 10:41:55 bert kernel: [ 1190.095156]  [<ffffffff812ca2d3>] kobject_i=
nit_and_add+0x53/0x70
Dec  8 10:41:55 bert kernel: [ 1190.095158]  [<ffffffff8139475f>] sysdev_re=
gister+0x6f/0xf0
Dec  8 10:41:55 bert kernel: [ 1190.095160]  [<ffffffff81598f38>] register_=
cpu_node+0x32/0x88
Dec  8 10:41:55 bert kernel: [ 1190.095162]  [<ffffffff8158207e>] arch_regi=
ster_cpu_node+0x3e/0x40
Dec  8 10:41:55 bert kernel: [ 1190.095164]  [<ffffffff8101220e>] arch_cpu_=
probe+0x10e/0x1f0
Dec  8 10:41:55 bert kernel: [ 1190.095166]  [<ffffffff813989d4>] cpu_probe=
_store+0x14/0x20
Dec  8 10:41:55 bert kernel: [ 1190.095168]  [<ffffffff81393ef0>] sysdev_cl=
ass_store+0x20/0x30
Dec  8 10:41:55 bert kernel: [ 1190.095170]  [<ffffffff811cd925>] sysfs_wri=
te_file+0xe5/0x170
Dec  8 10:41:55 bert kernel: [ 1190.095172]  [<ffffffff811624c8>] vfs_write=
+0xc8/0x190
Dec  8 10:41:55 bert kernel: [ 1190.095174]  [<ffffffff81162e61>] sys_write=
+0x51/0x90
Dec  8 10:41:55 bert kernel: [ 1190.095176]  [<ffffffff8100c142>] system_ca=
ll_fastpath+0x16/0x1b

Am I doing something wrong?

Thanks,
Eric


On Wed, 08 Dec 2010, Shaohui Zheng wrote:

> On Tue, Dec 07, 2010 at 11:24:20AM -0700, Eric B Munson wrote:
> > Shaohui,
> >=20
> > The documentation patch seems to be stale, it needs to be updated to ma=
tch the
> > new file names.
> >=20
> Eric,
> 	the major change on the patchset is on the interface, for the v8 emulato=
r,
> we accept David's per-node debugfs add_memory interface, we already inclu=
ded
> in the documentation patch. the change is very small, so it is not obviou=
s.
>=20
> This is the change on the documentation compare with v7:
> +3) Memory hotplug emulation:
> +
> +The emulator reserves memory before OS boots, the reserved memory region=
 is
> +removed from e820 table. Each online node has an add_memory interface, a=
nd
> +memory can be hot-added via the per-ndoe add_memory debugfs interface.
> +
> +The difficulty of Memory Release is well-known, we have no plan for it u=
ntil
> +now.
> +
> + - reserve memory thru a kernel boot paramter
> + 	mem=3D1024m
> +
> + - add a memory section to node 3
> +    # echo 0x40000000 > mem_hotplug/node3/add_memory
> +	OR
> +    # echo 1024m > mem_hotplug/node3/add_memory
> +
>=20
> --=20
> Thanks & Regards,
> Shaohui
>=20

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM/8R5AAoJEH65iIruGRnNaqEH/R3EXh/Ut3XN5pN9t6rysYbo
p8HuddHBhXoOA5ExtOi4mjfERfvM1Y49c1diGQHdWMViUuh3yuW2nSKquyzJG6ur
3yJRh2t4sfgqI7Qivun3+vGWgPWbXJspgCNuP7XlZlOsGwEbvN2Kgq8IQYhrBrjf
qQeXSUUktDPWuArIfLKI5g3Ar7tFNzDG3mM22yMaqcBn6qyMpTbKsHZaTZABswUw
VARn0MEVl/BMvZKE2kOQt2jEQ2k0odjOXKw0a2cTRv9Klc/NAbdZaYTJz5C5lm9k
JQ90qy/K8mRLuBSIAxET96ZFsWjGOXgxNXTLhBL/PDAF2DbQG74MhjFyOVITntA=
=YG/U
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
