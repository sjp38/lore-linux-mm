Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C99A6B02C4
	for <linux-mm@kvack.org>; Thu, 11 May 2017 12:57:30 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 81so22970236iof.0
        for <linux-mm@kvack.org>; Thu, 11 May 2017 09:57:30 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id v73si1046002itv.72.2017.05.11.09.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 09:57:29 -0700 (PDT)
Subject: Re: Kernel problem
References: <DM5PR15MB13399384EF35EF4451D31C2183ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <bbde3fc7-fa8c-7872-1099-44a3c293ffba@infradead.org>
Date: Thu, 11 May 2017 09:57:25 -0700
MIME-Version: 1.0
In-Reply-To: <DM5PR15MB13399384EF35EF4451D31C2183ED0@DM5PR15MB1339.namprd15.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Vosberg <frank.vosberg@sscs.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/11/17 08:17, Frank Vosberg wrote:
> Hi all,
> 
>  
> 
> I got the following message where I found this mail address, so can you let me what is wrong with the system ?



Try to make it readable (breaking the lines)...
 
  
>> kernel-default-3.0.101
Is this a new kernel for you?  New installation or software upgrade?
or is it just a new message?


What distro kernel is this?  For a kernel that old, you will probably
need to contact them.


I'll let someone else comment on the actual warning message:
Creating hierarchies with use_hierarchy==0 (flat hierarchy) is considered deprecated. If you believe that your setup is correct, we kindly ask you to contact linux-mm@kvack.org and let us know


May  6 18:04:03 musxaura006 kernel: [  142.119654] ------------[ cut here ]------------ 
May  6 18:04:03 musxaura006 kernel: [  142.119670] WARNING: at /usr/src/packages/BUILD/kernel-default-3.0.101/linux-3.0/mm/memcontrol.c:5028 mem_cgroup_create+0x394/0x4a0() 
May  6 18:04:03 musxaura006 kernel: [  142.119672] Hardware name: ProLiant DL580 G7 
May  6 18:04:03 musxaura006 kernel: [  142.119674] Creating hierarchies with use_hierarchy==0 (flat hierarchy) is considered deprecated. If you believe that your setup is correct, we kindly ask you to contact linux-mm@kvack.org and let us know 
May  6 18:04:03 musxaura006 kernel: [  142.119677] Modules linked in: mvfs(EX) nfsd autofs4 binfmt_misc ipmi_devintf edd rpcsec_gss_krb5 nfs lockd fscache auth_rpcgss nfs_acl sunrpc cpufreq_conservative cpufreq_userspace cpufreq_powersave pcc_cpufreq mperf nls_iso8859_1 nls_cp437 vfat fat loop dm_mod hpwdt netxen_nic hpilo ipv6_lib sg shpchp iTCO_wdt sr_mod i7core_edac iTCO_vendor_support edac_core
> cdrom ipmi_si pci_hotplug serio_raw acpi_power_meter pcspkr ipmi_msghandler rtc_cmos button container ext3 jbd mbcache radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core uhci_hcd ehci_hcd usbcore usb_common thermal processor thermal_sys hwmon scsi_dh_alua scsi_dh_rdac scsi_dh_emc scsi_dh_hp_sw scsi_dh ata_generic ata_piix libata hpsa cciss scsi_mod 
May  6 18:04:03 musxaura006 kernel: [  142.119726] Supported: Yes, External
May  6 18:04:03 musxaura006 kernel: [  142.119729] Pid: 8772, comm: java Tainted: G           E X 3.0.101-84-default #1
May  6 18:04:03 musxaura006 kernel: [  142.119731] Call Trace:
May  6 18:04:03 musxaura006 kernel: [  142.119746]  [<ffffffff81004b95>] dump_trace+0x75/0x300 May  6 18:04:03 musxaura006 kernel: [  142.119753]  [<ffffffff81466c03>] dump_stack+0x69/0x6f May  6 18:04:03 musxaura006 kernel: [  142.119761]  [<ffffffff81062157>] warn_slowpath_common+0x87/0xe0
May  6 18:04:03 musxaura006 kernel: [  142.119765]  [<ffffffff81062265>] warn_slowpath_fmt+0x45/0x60 
May  6 18:04:03 musxaura006 kernel: [  142.119769]  [<ffffffff81450ee4>] mem_cgroup_create+0x394/0x4a0 
May  6 18:04:03 musxaura006 kernel: [  142.119777]  [<ffffffff810b7b11>] cgroup_create+0x191/0x530 
May  6 18:04:03 musxaura006 kernel: [  142.119781]  [<ffffffff810b7ec4>] cgroup_mkdir+0x14/0x20 
May  6 18:04:03 musxaura006 kernel: [  142.119789]  [<ffffffff8116c7fd>] vfs_mkdir+0xad/0x130 May  6 18:04:03 musxaura006 kernel: [  142.119794]  [<ffffffff8116f755>] sys_mkdirat+0x165/0x180 
May  6 18:04:03 musxaura006 kernel: [  142.119801]  [<ffffffff81471df2>] system_call_fastpath+0x16/0x1b
May  6 18:04:03 musxaura006 kernel: [  142.119807]  [<00007f474b1c9967>] 0x7f474b1c9966 
May  6 18:04:03 musxaura006 kernel: [  142.119809] ---[ end trace 8db4a943075b8e6e ]---

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
