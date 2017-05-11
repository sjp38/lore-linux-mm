Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1646B02C4
	for <linux-mm@kvack.org>; Thu, 11 May 2017 13:30:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w131so12673149qka.5
        for <linux-mm@kvack.org>; Thu, 11 May 2017 10:30:38 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0129.outbound.protection.outlook.com. [104.47.33.129])
        by mx.google.com with ESMTPS id f93si525649qtb.152.2017.05.11.10.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 May 2017 10:30:37 -0700 (PDT)
From: Frank Vosberg <frank.vosberg@sscs.com>
Subject: AW: Kernel problem
Date: Thu, 11 May 2017 17:30:34 +0000
Message-ID: <DM5PR15MB1339E269FD516FD2B9EFC0A883ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
References: <DM5PR15MB13399384EF35EF4451D31C2183ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
 <bbde3fc7-fa8c-7872-1099-44a3c293ffba@infradead.org>
In-Reply-To: <bbde3fc7-fa8c-7872-1099-44a3c293ffba@infradead.org>
Content-Language: de-DE
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

It is just a new message, the same kernel is running on 2 other systems wit=
h the same config (Hard and soft config )fine.
I can not see any hardware problems in the HP ILO files.

Can it be a hardware problem may be too many mem errors, which are not show=
ing up in the HP IOL ?

-----Urspr=FCngliche Nachricht-----
Von: Randy Dunlap [mailto:rdunlap@infradead.org]
Gesendet: Donnerstag, 11. Mai 2017 18:57
An: Frank Vosberg <frank.vosberg@sscs.com>; linux-mm@kvack.org
Betreff: Re: Kernel problem

On 05/11/17 08:17, Frank Vosberg wrote:
> Hi all,
>
>
>
> I got the following message where I found this mail address, so can you l=
et me what is wrong with the system ?



Try to make it readable (breaking the lines)...


>> kernel-default-3.0.101
Is this a new kernel for you?  New installation or software upgrade?
or is it just a new message?



What distro kernel is this?  For a kernel that old, you will probably need =
to contact them.


I'll let someone else comment on the actual warning message:
Creating hierarchies with use_hierarchy=3D=3D0 (flat hierarchy) is consider=
ed deprecated. If you believe that your setup is correct, we kindly ask you=
 to contact linux-mm@kvack.org and let us know


May  6 18:04:03 musxaura006 kernel: [  142.119654] ------------[ cut here ]=
------------ May  6 18:04:03 musxaura006 kernel: [  142.119670] WARNING: at=
 /usr/src/packages/BUILD/kernel-default-3.0.101/linux-3.0/mm/memcontrol.c:5=
028 mem_cgroup_create+0x394/0x4a0() May  6 18:04:03 musxaura006 kernel: [  =
142.119672] Hardware name: ProLiant DL580 G7 May  6 18:04:03 musxaura006 ke=
rnel: [  142.119674] Creating hierarchies with use_hierarchy=3D=3D0 (flat h=
ierarchy) is considered deprecated. If you believe that your setup is corre=
ct, we kindly ask you to contact linux-mm@kvack.org and let us know May  6 =
18:04:03 musxaura006 kernel: [  142.119677] Modules linked in: mvfs(EX) nfs=
d autofs4 binfmt_misc ipmi_devintf edd rpcsec_gss_krb5 nfs lockd fscache au=
th_rpcgss nfs_acl sunrpc cpufreq_conservative cpufreq_userspace cpufreq_pow=
ersave pcc_cpufreq mperf nls_iso8859_1 nls_cp437 vfat fat loop dm_mod hpwdt=
 netxen_nic hpilo ipv6_lib sg shpchp iTCO_wdt sr_mod i7core_edac iTCO_vendo=
r_support edac_core
> cdrom ipmi_si pci_hotplug serio_raw acpi_power_meter pcspkr
> ipmi_msghandler rtc_cmos button container ext3 jbd mbcache radeon ttm
> drm_kms_helper drm i2c_algo_bit i2c_core uhci_hcd ehci_hcd usbcore
> usb_common thermal processor thermal_sys hwmon scsi_dh_alua
> scsi_dh_rdac scsi_dh_emc scsi_dh_hp_sw scsi_dh ata_generic ata_piix
> libata hpsa cciss scsi_mod
May  6 18:04:03 musxaura006 kernel: [  142.119726] Supported: Yes, External
May  6 18:04:03 musxaura006 kernel: [  142.119729] Pid: 8772, comm: java Ta=
inted: G           E X 3.0.101-84-default #1
May  6 18:04:03 musxaura006 kernel: [  142.119731] Call Trace:
May  6 18:04:03 musxaura006 kernel: [  142.119746]  [<ffffffff81004b95>] du=
mp_trace+0x75/0x300 May  6 18:04:03 musxaura006 kernel: [  142.119753]  [<f=
fffffff81466c03>] dump_stack+0x69/0x6f May  6 18:04:03 musxaura006 kernel: =
[  142.119761]  [<ffffffff81062157>] warn_slowpath_common+0x87/0xe0 May  6 =
18:04:03 musxaura006 kernel: [  142.119765]  [<ffffffff81062265>] warn_slow=
path_fmt+0x45/0x60 May  6 18:04:03 musxaura006 kernel: [  142.119769]  [<ff=
ffffff81450ee4>] mem_cgroup_create+0x394/0x4a0 May  6 18:04:03 musxaura006 =
kernel: [  142.119777]  [<ffffffff810b7b11>] cgroup_create+0x191/0x530 May =
 6 18:04:03 musxaura006 kernel: [  142.119781]  [<ffffffff810b7ec4>] cgroup=
_mkdir+0x14/0x20 May  6 18:04:03 musxaura006 kernel: [  142.119789]  [<ffff=
ffff8116c7fd>] vfs_mkdir+0xad/0x130 May  6 18:04:03 musxaura006 kernel: [  =
142.119794]  [<ffffffff8116f755>] sys_mkdirat+0x165/0x180 May  6 18:04:03 m=
usxaura006 kernel: [  142.119801]  [<ffffffff81471df2>] system_call_fastpat=
h+0x16/0x1b May  6 18:04:03 musxaura006 kernel: [  142.119807]  [<00007f474=
b1c9967>] 0x7f474b1c9966 May  6 18:04:03 musxaura006 kernel: [  142.119809]=
 ---[ end trace 8db4a943075b8e6e ]---

--
~Randy
CONFIDENTIALITY NOTE: The information contained in this message may be priv=
ileged, confidential, and protected from disclosure. If the reader of this =
message is not the intended recipient, or any employee or agent responsible=
 for delivering this message to the intended recipient, you are hereby noti=
fied that any dissemination, distribution or copying of this communication =
is strictly prohibited. If you have received this communication in error, p=
lease notify us immediately by replying to the message and deleting it from=
 your computer. Thank you. SSCS, Inc. 800-833-8223
CONFIDENTIALITY NOTE: The information contained in this message may be priv=
ileged, confidential, and protected from disclosure. If the reader of this =
message is not the intended recipient, or any employee or agent responsible=
 for delivering this message to the intended recipient, you are hereby noti=
fied that any dissemination, distribution or copying of this communication =
is strictly prohibited. If you have received this communication in error, p=
lease notify us immediately by replying to the message and deleting it from=
 your computer. Thank you. SSCS, Inc. 800-833-8223

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
