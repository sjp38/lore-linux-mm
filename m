Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 266DE6B0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 11:50:35 -0500 (EST)
Received: by mail-ia0-f174.google.com with SMTP id u20so599392iag.33
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 08:50:35 -0800 (PST)
MIME-Version: 1.0
From: Alexander R <aleromex@gmail.com>
Date: Thu, 7 Mar 2013 20:50:05 +0400
Message-ID: <CANkm-Fhz2A3vg_egsm15Siimi4X5AQrx0cYyFNAGNcEG5=3_JA@mail.gmail.com>
Subject: kernel trace
Content-Type: multipart/alternative; boundary=e89a8f23481569202704d758816b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--e89a8f23481569202704d758816b
Content-Type: text/plain; charset=UTF-8

Hi,

i use opensuse12.2 x86_64.

May be it would helpfully for your development

[   51.943819] ------------[ cut here ]------------
[   51.943838] WARNING: at
/home/abuild/rpmbuild/BUILD/kernel-default-3.4.28/linux-3.4/mm/memcontrol.c:5007
mem_cgroup_create+0x3ac/0x510()
[   51.943841] Hardware name: ProLiant DL560 Gen8
[   51.943842] Creating hierarchies with use_hierarchy==0 (flat hierarchy)
is considered deprecated. If you believe that your setup is correct, we
kindly ask you to contact linux-mm@kvack.org and let us know
[   51.943844] Modules linked in: ip6table_filter ip6_tables iptable_filter
ip_tables ebtable_nat ebtables x_tables nfs fscache nfsd lockd auth_rpcgss
nfs_acl sunrpc bridge stp kvm_intel kvm usb_storage joydev sg bnx2x mperf
coretemp crc32c_intel ghash_clmulni_intel aesni_intel cryptd crc32c
aes_x86_64 sb_edac ioatdma dca hpilo iTCO_wdt hpwdt libcrc32c
iTCO_vendor_support mdio edac_core pcspkr serio_raw tg3 button container
acpi_power_meter sha1_ssse3 sha1_generic arc4 ecb ppp_mppe ppp_generic slhc
microcode autofs4 usbhid uhci_hcd ehci_hcd usbcore usb_common thermal
processor thermal_sys scsi_dh_emc scsi_dh_hp_sw scsi_dh_alua scsi_dh_rdac
scsi_dh hpsa
[   51.943880] Pid: 7222, comm: libvirtd Tainted: G        W
 3.4.28-2.20-default #1
[   51.943882] Call Trace:
[   51.943909]  [<ffffffff81004598>] dump_trace+0x78/0x2c0
[   51.943920]  [<ffffffff81532e6a>] dump_stack+0x69/0x6f
[   51.943926]  [<ffffffff8103ead9>] warn_slowpath_common+0x79/0xc0
[   51.943931]  [<ffffffff8103ebd5>] warn_slowpath_fmt+0x45/0x50
[   51.943934]  [<ffffffff8151c04c>] mem_cgroup_create+0x3ac/0x510
[   51.943944]  [<ffffffff810a7983>] cgroup_mkdir+0x103/0x3a0
[   51.943952]  [<ffffffff81160345>] vfs_mkdir+0xb5/0x170
[   51.943958]  [<ffffffff81164444>] sys_mkdirat+0xe4/0xf0
[   51.943968]  [<ffffffff81545c7d>] system_call_fastpath+0x1a/0x1f
[   51.943974]  [<00007f12ed256f77>] 0x7f12ed256f76
[   51.943975] ---[ end trace a6c54db610fd5bb5 ]---

--e89a8f23481569202704d758816b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style>Hi,</div><div style><br></div><div style>i use =
opensuse12.2 x86_64.</div><div style><br></div><div style>May be it would h=
elpfully for your development</div><div><br></div><div>[ =C2=A0 51.943819] =
------------[ cut here ]------------</div>

<div>[ =C2=A0 51.943838] WARNING: at /home/abuild/rpmbuild/BUILD/kernel-def=
ault-3.4.28/linux-3.4/mm/memcontrol.c:5007 mem_cgroup_create+0x3ac/0x510()<=
/div><div>[ =C2=A0 51.943841] Hardware name: ProLiant DL560 Gen8</div><div>=
[ =C2=A0 51.943842] Creating hierarchies with use_hierarchy=3D=3D0 (flat hi=
erarchy) is considered deprecated. If you believe that your setup is correc=
t, we kindly ask you to contact <a href=3D"mailto:linux-mm@kvack.org">linux=
-mm@kvack.org</a> and let us know</div>

<div>[ =C2=A0 51.943844] Modules linked in: ip6table_filter ip6_tables ipta=
ble_filter ip_tables ebtable_nat ebtables x_tables nfs fscache nfsd lockd a=
uth_rpcgss nfs_acl sunrpc bridge stp kvm_intel kvm usb_storage joydev sg bn=
x2x mperf coretemp crc32c_intel ghash_clmulni_intel aesni_intel cryptd crc3=
2c aes_x86_64 sb_edac ioatdma dca hpilo iTCO_wdt hpwdt libcrc32c iTCO_vendo=
r_support mdio edac_core pcspkr serio_raw tg3 button container acpi_power_m=
eter sha1_ssse3 sha1_generic arc4 ecb ppp_mppe ppp_generic slhc microcode a=
utofs4 usbhid uhci_hcd ehci_hcd usbcore usb_common thermal processor therma=
l_sys scsi_dh_emc scsi_dh_hp_sw scsi_dh_alua scsi_dh_rdac scsi_dh hpsa</div=
>

<div>[ =C2=A0 51.943880] Pid: 7222, comm: libvirtd Tainted: G =C2=A0 =C2=A0=
 =C2=A0 =C2=A0W =C2=A0 =C2=A03.4.28-2.20-default #1</div><div>[ =C2=A0 51.9=
43882] Call Trace:</div><div>[ =C2=A0 51.943909] =C2=A0[&lt;ffffffff8100459=
8&gt;] dump_trace+0x78/0x2c0</div><div>[ =C2=A0 51.943920] =C2=A0[&lt;fffff=
fff81532e6a&gt;] dump_stack+0x69/0x6f</div>

<div>[ =C2=A0 51.943926] =C2=A0[&lt;ffffffff8103ead9&gt;] warn_slowpath_com=
mon+0x79/0xc0</div><div>[ =C2=A0 51.943931] =C2=A0[&lt;ffffffff8103ebd5&gt;=
] warn_slowpath_fmt+0x45/0x50</div><div>[ =C2=A0 51.943934] =C2=A0[&lt;ffff=
ffff8151c04c&gt;] mem_cgroup_create+0x3ac/0x510</div>

<div>[ =C2=A0 51.943944] =C2=A0[&lt;ffffffff810a7983&gt;] cgroup_mkdir+0x10=
3/0x3a0</div><div>[ =C2=A0 51.943952] =C2=A0[&lt;ffffffff81160345&gt;] vfs_=
mkdir+0xb5/0x170</div><div>[ =C2=A0 51.943958] =C2=A0[&lt;ffffffff81164444&=
gt;] sys_mkdirat+0xe4/0xf0</div>

<div>[ =C2=A0 51.943968] =C2=A0[&lt;ffffffff81545c7d&gt;] system_call_fastp=
ath+0x1a/0x1f</div><div>[ =C2=A0 51.943974] =C2=A0[&lt;00007f12ed256f77&gt;=
] 0x7f12ed256f76</div><div>[ =C2=A0 51.943975] ---[ end trace a6c54db610fd5=
bb5 ]---</div></div>


--e89a8f23481569202704d758816b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
