Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDE626B02F8
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 12:33:37 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id j68so2684173oih.10
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 09:33:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u205sor256540oif.75.2018.02.22.09.33.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 09:33:36 -0800 (PST)
Subject: Re: kernel BUG at mm/khugepaged.c:533 on 4.15.3
References: <2a152301-0535-6cb6-8823-44035f007fae@redhat.com>
 <20180221091445.iqtncxx66etpqamt@node.shutemov.name>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <70a4ca16-0d54-5df4-15bb-fdf1538ef080@redhat.com>
Date: Thu, 22 Feb 2018 09:33:32 -0800
MIME-Version: 1.0
In-Reply-To: <20180221091445.iqtncxx66etpqamt@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux-MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 02/21/2018 01:14 AM, Kirill A. Shutemov wrote:
> On Mon, Feb 19, 2018 at 10:51:01AM -0800, Laura Abbott wrote:
>> Hi,
>>
>> Fedora got a bug report of a BUG with 4.15.3:
>> (https://bugzilla.redhat.com/show_bug.cgi?id=1546709)
> 
> Is it new to v4.15 kernel?
> I don't see any recent change that could cause it.
> 

The original reporter only saw it on 4.15 but another reporter
saw it on 4.14.13 (I only found this out after I sent the
e-mail). So I suspect the bug may have been latent but
hard to trigger.

> 
>> page:fffffac1800a0000 count:513 mapcount:1 mapping:ffff95657ef359a1 index:0x7f95d3400 compound_mapcount: 0
>> flags: 0xffffe00048268(uptodate|lru|active|owner_priv_1|head|swapbacked)
>> raw: 000ffffe00048268 ffff95657ef359a1 00000007f95d3400 0000020100000000
>> raw: fffffac18edea9a0 fffffac18e7085a0 00000000000db400 ffff9567a3269800
>> page dumped because: VM_BUG_ON_PAGE(PageCompound(page))
>> page->mem_cgroup:ffff9567a3269800
>> ------------[ cut here ]------------
>> kernel BUG at mm/khugepaged.c:533!
>> invalid opcode: 0000 [#1] SMP PTI
>> Modules linked in: vhost_net vhost tap fuse xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw ip6table_security iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack libcrc32c iptable_mangle iptable_raw iptable_security ebtable_filter ebtables ip6table_filter ip6_tables sunrpc vfat fat rmi_smbus rmi_core arc4 intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp snd_hda_codec_hdmi iwlmvm kvm_intel iTCO_wdt mac80211 snd_hda_codec_realtek iTCO_vendor_support mei_wdt kvm snd_hda_codec_generic irqbypass intel_cstate snd_hda_intel intel_uncore iwlwifi uvcvideo intel_rapl_perf
>> snd_hda_codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core snd_hda_core cfg80211 videodev snd_hwdep snd_seq snd_seq_device snd_pcm media mei_me snd_timer thinkpad_acpi wmi_bmof rtsx_pci_ms joydev tpm_tis memstick i2c_i801 mei tpm_tis_core snd soundcore intel_pch_thermal tpm shpchp rfkill dm_crypt hid_logitech_hidpp hid_logitech_dj mmc_block nouveau i915 rtsx_pci_sdmmc mmc_core mxm_wmi ttm e1000e i2c_algo_bit drm_kms_helper crct10dif_pclmul crc32_pclmul crc32c_intel ptp drm ghash_clmulni_intel serio_raw rtsx_pci pps_core wmi video
>> CPU: 2 PID: 66 Comm: khugepaged Not tainted 4.15.3-300.fc27.x86_64 #1
>> Hardware name: LENOVO 20FXS0BB14/20FXS0BB14, BIOS R07ET63W (2.03 ) 03/15/2016
>> RIP: 0010:khugepaged+0x1af6/0x2130
>> RSP: 0018:ffffacacc1b4bdc0 EFLAGS: 00010282
>> RAX: 0000000000000021 RBX: fffffac1800a0000 RCX: 0000000000000006
>> RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff9567c14968f0
>> RBP: fffffac18e3a5b40 R08: 00000000000004a8 R09: 0000000000000004
>> R10: ffffacacc1b4bd70 R11: ffffffffb995b1ed R12: 00007f95f7e00000
>> R13: ffff95661113eaf0 R14: ffff9567a9ea0000 R15: 8000000002800825
>> FS:  0000000000000000(0000) GS:ffff9567c1480000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000000481046 CR3: 00000002ee20a005 CR4: 00000000003626e0
>> Call Trace:
>> ? finish_wait+0x80/0x80
>> ? collapse_shmem+0xdd0/0xdd0
>> kthread+0x113/0x130
>> ? kthread_create_worker_on_cpu+0x70/0x70
>> ret_from_fork+0x35/0x40
>> Code: ff e9 e7 fd ff ff bb 07 00 00 00 49 89 c7 e9 20 fb ff ff 48 83 ea 01 e9 66 fc ff ff 48 c7 c6 d8 3f 0a b9 48 89 df e8 0a 82 fa ff <0f> 0b 31 c9 4c 89 fa 48 89 de 4c 89 f7 e8 58 f1 fd ff e9 2e fa
>> RIP: khugepaged+0x1af6/0x2130 RSP: ffffacacc1b4bdc0
>> ---[ end trace a734c2f4d682e3bd ]---
>>
>> Reporter said it happened several times. Config is attached.
>> Any ideas?
> 
> Looks like somebody managed to insert THP into the range in split it back
> between khugepaged_scan_pmd() and __collapse_huge_page_isolate().
> 
> That's rather unlikely chain of events, but I don't see other option.
> 
> Could you check if this works:
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index b7e2268dfc9a..c15da1ea7e63 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -530,7 +530,12 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   			goto out;
>   		}
>   
> -		VM_BUG_ON_PAGE(PageCompound(page), page);
> +		/* TODO: teach khugepaged to collapse THP mapped with pte */
> +		if (PageCompound(page)) {
> +			result = SCAN_PAGE_COMPOUND;
> +			goto out;
> +		}
> +
>   		VM_BUG_ON_PAGE(!PageAnon(page), page);
>   
>   		/*
> 

I asked the reporter(s) to test with this patch. I'll let you know
if I hear any results.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
