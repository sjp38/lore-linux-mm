Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFD16B02C4
	for <linux-mm@kvack.org>; Thu, 11 May 2017 11:18:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p86so21857231pfl.12
        for <linux-mm@kvack.org>; Thu, 11 May 2017 08:18:03 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0125.outbound.protection.outlook.com. [104.47.38.125])
        by mx.google.com with ESMTPS id u12si400960pgn.138.2017.05.11.08.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 May 2017 08:18:01 -0700 (PDT)
From: Frank Vosberg <frank.vosberg@sscs.com>
Subject: Kernel problem
Date: Thu, 11 May 2017 15:17:59 +0000
Message-ID: <DM5PR15MB13399384EF35EF4451D31C2183ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
Content-Language: de-DE
Content-Type: multipart/alternative;
	boundary="_000_DM5PR15MB13399384EF35EF4451D31C2183ED0DM5PR15MB1339namp_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

--_000_DM5PR15MB13399384EF35EF4451D31C2183ED0DM5PR15MB1339namp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi all,

I got the following message where I found this mail address, so can you let=
 me what is wrong with the system ?




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
r_support edac_core cdrom ipmi_si pci_hotplug serio_raw acpi_power_meter pc=
spkr ipmi_msghandler rtc_cmos button container ext3 jbd mbcache radeon ttm =
drm_kms_helper drm i2c_algo_bit i2c_core uhci_hcd ehci_hcd usbcore usb_comm=
on thermal processor thermal_sys hwmon scsi_dh_alua scsi_dh_rdac scsi_dh_em=
c scsi_dh_hp_sw scsi_dh ata_generic ata_piix libata hpsa cciss scsi_mod May=
  6 18:04:03 musxaura006 kernel: [  142.119726] Supported: Yes, External
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

Mit freundlichen Gr=FCssen / Kind Regards

Frank Vosberg
Service Delivery Manager DACH

Solid Systems CAD Services GmbH
Nobelstrasse 1a
DE - 85757 Karlsfeld

+49 176 15858700  Mobile
+1.877.904.7727  Global Call Center

frank.vosberg@sscs.com<mailto:frank.vosberg@sscs.com>
www.sscs.com<http://www.sscs.com/>

Gesch=E4ftsf=FChrer: William H. Olund, Gahlen W. Carpenter, Anja Harrell
Registergericht M=FCnchen, HRB 218212

CONFIDENTIALITY NOTE: The information contained in this message may be priv=
ileged, confidential, and protected from disclosure. If the reader of this =
message is not the intended recipient, or any employee or agent responsible=
 for delivering this message to the intended recipient, you are hereby noti=
fied that any dissemination, distribution or copying of this communication =
is strictly prohibited. If you have received this communication in error, p=
lease notify us immediately by replying to the message and deleting it from=
 your computer. Thank you. SSCS, Inc. 800-833-8223

--_000_DM5PR15MB13399384EF35EF4451D31C2183ED0DM5PR15MB1339namp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
span.E-MailFormatvorlage17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;
	mso-fareast-language:EN-US;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:70.85pt 70.85pt 2.0cm 70.85pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"DE" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US">Hi all,<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">I got the following message whe=
re I found this mail address, so can you let me what is wrong with the syst=
em ?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">May&nbsp; 6 18:04:03 musxaura00=
6 kernel: [&nbsp; 142.119654] ------------[ cut here ]------------ May&nbsp=
; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119670] WARNING: at /usr/src/p=
ackages/BUILD/kernel-default-3.0.101/linux-3.0/mm/memcontrol.c:5028
 mem_cgroup_create&#43;0x394/0x4a0() May&nbsp; 6 18:04:03 musxaura006 kerne=
l: [&nbsp; 142.119672] Hardware name: ProLiant DL580 G7 May&nbsp; 6 18:04:0=
3 musxaura006 kernel: [&nbsp; 142.119674] Creating hierarchies with use_hie=
rarchy=3D=3D0 (flat hierarchy) is considered deprecated. If
 you believe that your setup is correct, we kindly ask you to contact linux=
-mm@kvack.org and let us know May&nbsp; 6 18:04:03 musxaura006 kernel: [&nb=
sp; 142.119677] Modules linked in: mvfs(EX) nfsd autofs4 binfmt_misc ipmi_d=
evintf edd rpcsec_gss_krb5 nfs lockd fscache
 auth_rpcgss nfs_acl sunrpc cpufreq_conservative cpufreq_userspace cpufreq_=
powersave pcc_cpufreq mperf nls_iso8859_1 nls_cp437 vfat fat loop dm_mod hp=
wdt netxen_nic hpilo ipv6_lib sg shpchp iTCO_wdt sr_mod i7core_edac iTCO_ve=
ndor_support edac_core cdrom ipmi_si
 pci_hotplug serio_raw acpi_power_meter pcspkr ipmi_msghandler rtc_cmos but=
ton container ext3 jbd mbcache radeon ttm drm_kms_helper drm i2c_algo_bit i=
2c_core uhci_hcd ehci_hcd usbcore usb_common thermal processor thermal_sys =
hwmon scsi_dh_alua scsi_dh_rdac
 scsi_dh_emc scsi_dh_hp_sw scsi_dh ata_generic ata_piix libata hpsa cciss s=
csi_mod May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119726] Suppor=
ted: Yes, External<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">May&nbsp; 6 18:04:03 musxaura00=
6 kernel: [&nbsp; 142.119729] Pid: 8772, comm: java Tainted: G&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; E X 3.0.101-84-default #1<o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">May&nbsp; 6 18:04:03 musxaura00=
6 kernel: [&nbsp; 142.119731] Call Trace:<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US">May&nbsp; 6 18:04:03 musxaura00=
6 kernel: [&nbsp; 142.119746]&nbsp; [&lt;ffffffff81004b95&gt;] dump_trace&#=
43;0x75/0x300 May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119753]&=
nbsp; [&lt;ffffffff81466c03&gt;] dump_stack&#43;0x69/0x6f May&nbsp; 6 18:04=
:03 musxaura006
 kernel: [&nbsp; 142.119761]&nbsp; [&lt;ffffffff81062157&gt;] warn_slowpath=
_common&#43;0x87/0xe0 May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.=
119765]&nbsp; [&lt;ffffffff81062265&gt;] warn_slowpath_fmt&#43;0x45/0x60 Ma=
y&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119769]&nbsp; [&lt;fffff=
fff81450ee4&gt;] mem_cgroup_create&#43;0x394/0x4a0
 May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119777]&nbsp; [&lt;ff=
ffffff810b7b11&gt;] cgroup_create&#43;0x191/0x530 May&nbsp; 6 18:04:03 musx=
aura006 kernel: [&nbsp; 142.119781]&nbsp; [&lt;ffffffff810b7ec4&gt;] cgroup=
_mkdir&#43;0x14/0x20 May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.1=
19789]&nbsp; [&lt;ffffffff8116c7fd&gt;]
 vfs_mkdir&#43;0xad/0x130 May&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; =
142.119794]&nbsp; [&lt;ffffffff8116f755&gt;] sys_mkdirat&#43;0x165/0x180 Ma=
y&nbsp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119801]&nbsp; [&lt;fffff=
fff81471df2&gt;] system_call_fastpath&#43;0x16/0x1b May&nbsp; 6 18:04:03 mu=
sxaura006 kernel:
 [&nbsp; 142.119807]&nbsp; [&lt;00007f474b1c9967&gt;] 0x7f474b1c9966 May&nb=
sp; 6 18:04:03 musxaura006 kernel: [&nbsp; 142.119809] ---[ end trace 8db4a=
943075b8e6e ]---<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"NL" style=3D"font-size:10.0pt;font-fam=
ily:&quot;Tahoma&quot;,sans-serif;color:#1F497D;mso-fareast-language:DE">Mi=
t freundlichen Gr=FCssen / Kind Regards<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"color:#1F497D;mso-fareast-language:DE=
"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><b><span style=3D"font-size:10.0pt;color:#00953A;mso=
-fareast-language:DE">Frank Vosberg</span></b><span style=3D"color:#1F497D;=
mso-fareast-language:DE"><o:p></o:p></span></p>
<p class=3D"MsoNormal"><b><span lang=3D"EN-GB" style=3D"font-size:9.0pt;col=
or:#1F497D;mso-fareast-language:DE">Service Delivery Manager DACH<o:p></o:p=
></span></b></p>
<p class=3D"MsoNormal"><span lang=3D"EN-GB" style=3D"font-size:4.0pt;color:=
#1F497D;mso-fareast-language:DE">&nbsp;</span><span lang=3D"EN-GB" style=3D=
"color:#1F497D;mso-fareast-language:DE"><o:p></o:p></span></p>
<p class=3D"MsoNormal"><b><span lang=3D"EN-GB" style=3D"font-size:10.0pt;co=
lor:#00953A;mso-fareast-language:DE">Solid Systems CAD Services GmbH</span>=
</b><span lang=3D"EN-GB" style=3D"color:#1F497D;mso-fareast-language:DE"><o=
:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-GB" style=3D"font-size:9.0pt;color:=
#1F497D;mso-fareast-language:DE">Nobelstrasse 1a<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-GB" style=3D"font-size:9.0pt;color:=
#1F497D;mso-fareast-language:DE">DE - 85757 Karlsfeld<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-GB" style=3D"font-size:9.0pt;color:=
#1F497D;mso-fareast-language:DE">&nbsp;<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;color:=
#1F497D;mso-fareast-language:DE">&#43;49 176 15858700&nbsp;
<b>Mobile</b><o:p></o:p></span></p>
<p class=3D"MsoNormal" style=3D"text-autospace:none"><span lang=3D"EN-US" s=
tyle=3D"font-size:9.0pt;color:#1F497D;mso-fareast-language:DE">&#43;1.877.9=
04.7727&nbsp;
<b>Global Call Center</b><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:4.0pt;color:=
#1F497D;mso-fareast-language:DE">&nbsp;</span><span lang=3D"EN-US" style=3D=
"color:#1F497D;mso-fareast-language:DE"><o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"font-size:9.0pt;color:=
#1F497D;mso-fareast-language:DE"><a href=3D"mailto:frank.vosberg@sscs.com">=
<span style=3D"color:#0563C1">frank.vosberg@sscs.com</span></a><o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:9.0pt;color:#1F497D;mso-far=
east-language:DE"><a href=3D"http://www.sscs.com/"><span lang=3D"EN-US" sty=
le=3D"color:#0563C1">www.sscs.com</span></a></span><span lang=3D"EN-US" sty=
le=3D"font-size:9.0pt;color:#1F497D;mso-fareast-language:DE"><o:p></o:p></s=
pan></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US" style=3D"color:#1F497D;mso-fare=
ast-language:DE"><o:p>&nbsp;</o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:9.0pt;color:#1F497D;mso-far=
east-language:DE">Gesch=E4ftsf=FChrer: William H. Olund, Gahlen W. Carpente=
r, Anja Harrell<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:9.0pt;color:#1F497D;mso-far=
east-language:DE">Registergericht M=FCnchen, HRB 218212&nbsp;
<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
</div>
CONFIDENTIALITY NOTE: The information contained in this message may be priv=
ileged, confidential, and protected from disclosure. If the reader of this =
message is not the intended recipient, or any employee or agent responsible=
 for delivering this message to
 the intended recipient, you are hereby notified that any dissemination, di=
stribution or copying of this communication is strictly prohibited. If you =
have received this communication in error, please notify us immediately by =
replying to the message and deleting
 it from your computer. Thank you. SSCS, Inc. 800-833-8223
</body>
</html>

--_000_DM5PR15MB13399384EF35EF4451D31C2183ED0DM5PR15MB1339namp_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
