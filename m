Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id A5A1F6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 22:17:19 -0500 (EST)
Date: Mon, 26 Nov 2012 22:16:55 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm/vmemmap: fix wrong use of virt_to_page
Message-ID: <20121127031655.GF2301@cmpxchg.org>
References: <50B422A9.7050103@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B422A9.7050103@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, shangw@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Tue, Nov 27, 2012 at 10:17:13AM +0800, Jianguo Wu wrote:
> I enable CONFIG_DEBUG_VIRTUAL and CONFIG_SPARSEMEM_VMEMMAP, when doing memory hotremove,
> there is a kernel BUG at arch/x86/mm/physaddr.c:20.
> 
> It is caused by free_section_usemap()->virt_to_page(),
> virt_to_page() is only used for kernel direct mapping address,
> but sparse-vmemmap uses vmemmap address, so it is going wrong here.
> 
> [  517.727381] ------------[ cut here ]------------
> [  517.728851] kernel BUG at arch/x86/mm/physaddr.c:20!
> [  517.728851] invalid opcode: 0000 [#1] SMP
> [  517.740170] Modules linked in: acpihp_drv acpihp_slot edd cpufreq_conservativ
> e cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf fuse vfat fat loop dm_m
> od coretemp kvm crc32c_intel ipv6 ixgbe igb iTCO_wdt i7core_edac edac_core pcspk
> r iTCO_vendor_support ioatdma microcode joydev sr_mod i2c_i801 dca lpc_ich mfd_c
> ore mdio tpm_tis i2c_core hid_generic tpm cdrom sg tpm_bios rtc_cmos button ext3
>  jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif p
> rocessor thermal_sys hwmon scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh_emc s
> csi_dh ata_generic ata_piix libata megaraid_sas scsi_mod
> [  517.740170] CPU 39
> [  517.740170] Pid: 6454, comm: sh Not tainted 3.7.0-rc1-acpihp-final+ #45 QCI Q
> SSC-S4R/QSSC-S4R
> [  517.740170] RIP: 0010:[<ffffffff8103c908>]  [<ffffffff8103c908>] __phys_addr+
> 0x88/0x90
> [  517.740170] RSP: 0018:ffff8804440d7c08  EFLAGS: 00010006
> [  517.740170] RAX: 0000000000000006 RBX: ffffea0012000000 RCX: 000000000000002c
> 
> [  517.740170] RDX: 0000620012000000 RSI: 0000000000000000 RDI: ffffea0012000000
> 
> [  517.740170] RBP: ffff8804440d7c08 R08: 0070000000000400 R09: 0000000000488000
> 
> [  517.740170] R10: 0000000000000091 R11: 0000000000000001 R12: ffff88047fb87800
> 
> [  517.740170] R13: ffffea0000000000 R14: ffff88047ffb3440 R15: 0000000000480000
> 
> [  517.740170] FS:  00007f0462b49700(0000) GS:ffff8804570c0000(0000) knlGS:00000
> 00000000000
> [  517.740170] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  517.740170] CR2: 00007f006dc5fd14 CR3: 0000000440e85000 CR4: 00000000000007e0
> 
> [  517.740170] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> 
> [  517.896799] DR3: 0000000000000000 DR6
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
