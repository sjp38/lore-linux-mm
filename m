Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5F66E280276
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 21:31:01 -0400 (EDT)
Received: by ykax123 with SMTP id x123so24055552yka.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 18:31:01 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t3si1988741ykc.79.2015.07.14.18.30.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 18:31:00 -0700 (PDT)
Message-ID: <55A5B7A2.1010202@huawei.com>
Date: Wed, 15 Jul 2015 09:30:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [linux-nics] [E1000-devel] bad pages when up/down network cable
References: <55A4C8F1.4000104@huawei.com> <CAD=hENdLy_K6LFE3Cm2nfxxVOhWRZWiJmKX5-EKdoBtnWP3MJQ@mail.gmail.com> <55A4D55A.2080903@huawei.com> <55A4D823.2090900@huawei.com> <F6FB0E698C9B3143BDF729DF22286646913127E5@ORSMSX110.amr.corp.intel.com>
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646913127E5@ORSMSX110.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Cc: zhuyj <zyjzyj2000@gmail.com>, guozhibin 00179312 <g00179312@notesmail.huawei.com.cn>, Linux MM <linux-mm@kvack.org>, Linux
 NICS <Linux-nics@isotope.jf.intel.com>, LKML <linux-kernel@vger.kernel.org>, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>

On 2015/7/14 22:40, Skidmore, Donald C wrote:

> Hey Xishi,
> 
> You are using a really old driver, our current is 4.1.1 and 3.9 dates to over 3 years ago.  We have makes changes to support surprise removal that very well may address this issue.  Have you attempted to recreate this failure with the latest out of tree driver?
> 
> Thanks,
> -Don <donald.c.skidmore@intel.com>
> 

Thank you very much, we'll try the latest driver.

Thanks,
Xishi Qiu

> 
> 
>> -----Original Message-----
>> From: linux-nics-bounces@isotope.jf.intel.com [mailto:linux-nics-
>> bounces@isotope.jf.intel.com] On Behalf Of Xishi Qiu
>> Sent: Tuesday, July 14, 2015 2:37 AM
>> To: zhuyj
>> Cc: guozhibin 00179312; Linux MM; Linux NICS; LKML; e1000-
>> devel@lists.sourceforge.net
>> Subject: Re: [linux-nics] [E1000-devel] bad pages when up/down network
>> cable
>>
>> On 2015/7/14 17:24, Xishi Qiu wrote:
>>
>>> On 2015/7/14 17:00, zhuyj wrote:
>>>
>>>> Do you use the default ixgbe driver? or the ixgbe driver is modified by
>> you?
>>>>
>>>
>>> Yesi 1/4 ?no modify.
>>>
>>
>> Sorry, it is modified by us...
>>
>> the driver come from inteli 1/4 ?the infoi 1/4 ?
>> root:~ # ethtool -i p2p2
>> driver: ixgbe
>> version: 3.9.16-NAPI
>> firmware-version: 0x18f10001
>> bus-info: 0000:04:00.1
>> supports-statistics: yes
>> supports-test: yes
>> supports-eeprom-access: yes
>> supports-register-dump: yes
>>
>> Thanks,
>> Xishi Qiu
>>
>>>
>>>> On Tue, Jul 14, 2015 at 4:31 PM, Xishi Qiu <qiuxishi@huawei.com
>> <mailto:qiuxishi@huawei.com>> wrote:
>>>>
>>>>     1a??the host directly link to the storage devicei 1/4 ?by intel ixgbe NIC;
>>>>     between them, no switch or router.
>>>>     2a??the nic of the storage device suddenly become unused and then OK
>>>>     after a little time, this happened frequency.
>>>>     3a??the host printk a lot of message like these:
>>>>
>>>>     The kernel is SUSE 3.0.13, use slab, and the following log shows the
>>>>     page still have PG_slab when free_pages(). Does anyone have seen the
>>>>     problem?
>>>>
>>>>     Jul  9 11:31:36 root kernel: [1042291.977565] BUG: Bad page state in
>> process swapper  pfn:00bf2
>>>>     Jul  9 11:31:36 root kernel: [1042291.977568] page:ffffea0000029cf0
>> count:0 mapcount:0 mapping:          (null) index:0x7f6d4f500
>>>>     Jul  9 11:31:36 root kernel: [1042291.977571] page flags:
>> 0x40000000000100(slab)  // here is the reason
>>>>     Jul  9 11:31:36 root kernel: [1042291.977574] Pid: 0, comm: swapper
>> Tainted: G    B       X 3.0.13-0.27-default #1
>>>>     Jul  9 11:31:36 root kernel: [1042291.977577] Call Trace:
>>>>     Jul  9 11:31:36 root kernel: [1042291.977583]  [<ffffffff810048b5>]
>> dump_trace+0x75/0x300
>>>>     Jul  9 11:31:36 root kernel: [1042291.977639]  [<ffffffff8143ea0f>]
>> dump_stack+0x69/0x6f
>>>>     Jul  9 11:31:36 root kernel: [1042291.977644]  [<ffffffff810f53a1>]
>> bad_page+0xb1/0x120
>>>>     Jul  9 11:31:37 root kernel: [1042291.977649]  [<ffffffff810f5926>]
>> free_pages_prepare+0xe6/0x110
>>>>     Jul  9 11:31:37 root kernel: [1042291.977654]  [<ffffffff810f9259>]
>> free_hot_cold_page+0x49/0x1f0
>>>>     Jul  9 11:31:37 root kernel: [1042291.977660]  [<ffffffff8137a3b4>]
>> skb_release_data+0xb4/0xe0
>>>>     Jul  9 11:31:37 root kernel: [1042291.977665]  [<ffffffff81379e79>]
>> __kfree_skb+0x9/0x90
>>>>     Jul  9 11:31:37 root kernel: [1042291.977676]  [<ffffffffa02784a9>]
>> ixgbe_clean_tx_irq+0xa9/0x480 [ixgbe]
>>>>     Jul  9 11:31:37 root kernel: [1042291.977693]  [<ffffffffa02788cb>]
>> ixgbe_poll+0x4b/0x1a0 [ixgbe]
>>>>     Jul  9 11:31:37 root kernel: [1042291.977705]  [<ffffffff81389c3a>]
>> net_rx_action+0x10a/0x2c0
>>>>     Jul  9 11:31:37 root kernel: [1042291.977711]  [<ffffffff81060a1f>]
>> __do_softirq+0xef/0x220
>>>>     Jul  9 11:31:37 root kernel: [1042291.977716]  [<ffffffff8144a8bc>]
>> call_softirq+0x1c/0x30
>>>>     Jul  9 11:31:37 root kernel: [1042291.978974] DWARF2 unwinder stuck at
>> call_softirq+0x1c/0x30
>>>>
>>>>     Thanks,
>>>>     Xishi Qiu
>>>>
>>>>
>>>>     ------------------------------------------------------------------------------
>>>>     Don't Limit Your Business. Reach for the Cloud.
>>>>     GigeNET's Cloud Solutions provide you with the tools and support that
>>>>     you need to offload your IT needs and focus on growing your business.
>>>>     Configured For All Businesses. Start Your Cloud Today.
>>>>     https://www.gigenetcloud.com/
>>>>     _______________________________________________
>>>>     E1000-devel mailing list
>>>>     E1000-devel@lists.sourceforge.net <mailto:E1000-
>> devel@lists.sourceforge.net>
>>>>     https://lists.sourceforge.net/lists/listinfo/e1000-devel
>>>>     To learn more about Intel&#174; Ethernet, visit
>> http://communities.intel.com/community/wired
>>>>
>>>>
>>>
>>>
>>
>>
>>
>> _______________________________________________
>> Linux-nics mailing list
>> Linux-nics@intel.com



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
