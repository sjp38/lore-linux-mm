Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id E34449003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:28:29 -0400 (EDT)
Received: by oiab3 with SMTP id b3so2633249oia.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:28:29 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id f124si390884oih.59.2015.07.14.02.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 02:28:29 -0700 (PDT)
Message-ID: <55A4D55A.2080903@huawei.com>
Date: Tue, 14 Jul 2015 17:24:42 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [E1000-devel] bad pages when up/down network cable
References: <55A4C8F1.4000104@huawei.com> <CAD=hENdLy_K6LFE3Cm2nfxxVOhWRZWiJmKX5-EKdoBtnWP3MJQ@mail.gmail.com>
In-Reply-To: <CAD=hENdLy_K6LFE3Cm2nfxxVOhWRZWiJmKX5-EKdoBtnWP3MJQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhuyj <zyjzyj2000@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, guozhibin 00179312 <g00179312@notesmail.huawei.com.cn>, linux.nics@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>

On 2015/7/14 17:00, zhuyj wrote:

> Do you use the default ixgbe driver? or the ixgbe driver is modified by you?
> 

Yesi 1/4 ?no modify.

Thanks,
Xishi Qiu

> On Tue, Jul 14, 2015 at 4:31 PM, Xishi Qiu <qiuxishi@huawei.com <mailto:qiuxishi@huawei.com>> wrote:
> 
>     1a??the host directly link to the storage devicei 1/4 ?by intel ixgbe NIC;
>     between them, no switch or router.
>     2a??the nic of the storage device suddenly become unused and then OK
>     after a little time, this happened frequency.
>     3a??the host printk a lot of message like these:
> 
>     The kernel is SUSE 3.0.13, use slab, and the following log shows the
>     page still have PG_slab when free_pages(). Does anyone have seen the
>     problem?
> 
>     Jul  9 11:31:36 root kernel: [1042291.977565] BUG: Bad page state in process swapper  pfn:00bf2
>     Jul  9 11:31:36 root kernel: [1042291.977568] page:ffffea0000029cf0 count:0 mapcount:0 mapping:          (null) index:0x7f6d4f500
>     Jul  9 11:31:36 root kernel: [1042291.977571] page flags: 0x40000000000100(slab)  // here is the reason
>     Jul  9 11:31:36 root kernel: [1042291.977574] Pid: 0, comm: swapper Tainted: G    B       X 3.0.13-0.27-default #1
>     Jul  9 11:31:36 root kernel: [1042291.977577] Call Trace:
>     Jul  9 11:31:36 root kernel: [1042291.977583]  [<ffffffff810048b5>] dump_trace+0x75/0x300
>     Jul  9 11:31:36 root kernel: [1042291.977639]  [<ffffffff8143ea0f>] dump_stack+0x69/0x6f
>     Jul  9 11:31:36 root kernel: [1042291.977644]  [<ffffffff810f53a1>] bad_page+0xb1/0x120
>     Jul  9 11:31:37 root kernel: [1042291.977649]  [<ffffffff810f5926>] free_pages_prepare+0xe6/0x110
>     Jul  9 11:31:37 root kernel: [1042291.977654]  [<ffffffff810f9259>] free_hot_cold_page+0x49/0x1f0
>     Jul  9 11:31:37 root kernel: [1042291.977660]  [<ffffffff8137a3b4>] skb_release_data+0xb4/0xe0
>     Jul  9 11:31:37 root kernel: [1042291.977665]  [<ffffffff81379e79>] __kfree_skb+0x9/0x90
>     Jul  9 11:31:37 root kernel: [1042291.977676]  [<ffffffffa02784a9>] ixgbe_clean_tx_irq+0xa9/0x480 [ixgbe]
>     Jul  9 11:31:37 root kernel: [1042291.977693]  [<ffffffffa02788cb>] ixgbe_poll+0x4b/0x1a0 [ixgbe]
>     Jul  9 11:31:37 root kernel: [1042291.977705]  [<ffffffff81389c3a>] net_rx_action+0x10a/0x2c0
>     Jul  9 11:31:37 root kernel: [1042291.977711]  [<ffffffff81060a1f>] __do_softirq+0xef/0x220
>     Jul  9 11:31:37 root kernel: [1042291.977716]  [<ffffffff8144a8bc>] call_softirq+0x1c/0x30
>     Jul  9 11:31:37 root kernel: [1042291.978974] DWARF2 unwinder stuck at call_softirq+0x1c/0x30
> 
>     Thanks,
>     Xishi Qiu
> 
> 
>     ------------------------------------------------------------------------------
>     Don't Limit Your Business. Reach for the Cloud.
>     GigeNET's Cloud Solutions provide you with the tools and support that
>     you need to offload your IT needs and focus on growing your business.
>     Configured For All Businesses. Start Your Cloud Today.
>     https://www.gigenetcloud.com/
>     _______________________________________________
>     E1000-devel mailing list
>     E1000-devel@lists.sourceforge.net <mailto:E1000-devel@lists.sourceforge.net>
>     https://lists.sourceforge.net/lists/listinfo/e1000-devel
>     To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
