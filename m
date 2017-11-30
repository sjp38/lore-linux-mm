Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6F26B025E
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:08:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q13so4335110pgt.11
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:08:09 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j11si3118843plt.712.2017.11.30.06.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 06:08:07 -0800 (PST)
Date: Thu, 30 Nov 2017 22:08:04 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: dd: page allocation failure: order:0,
 mode:0x1080020(GFP_ATOMIC), nodemask=(null)
Message-ID: <20171130140804.74lgpkvmvnzx4dlm@wfg-t540p.sh.intel.com>
References: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
 <20171130135016.dfzj2s7ngz55tfws@dhcp22.suse.cz>
 <20171130140103.arapa4qphgtmjyqm@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="fqvh44pibocj3rev"
Content-Disposition: inline
In-Reply-To: <20171130140103.arapa4qphgtmjyqm@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, lkp@01.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>


--fqvh44pibocj3rev
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

>>> [   78.848629] dd: page allocation failure: order:0, mode:0x1080020(GFP_ATOMIC), nodemask=(null)
>>> [   78.857841] dd cpuset=/ mems_allowed=0-1
>>> [   78.862502] CPU: 0 PID: 6131 Comm: dd Tainted: G           O     4.15.0-rc1 #1
>>> [   78.870437] Call Trace:
>>> [   78.873610]  <IRQ>
>>> [   78.876342]  dump_stack+0x5c/0x7b
>>> [   78.880414]  warn_alloc+0xbe/0x150
>>> [   78.884550]  __alloc_pages_slowpath+0xda7/0xdf0
>>> [   78.889822]  ? xhci_urb_enqueue+0x23d/0x580
>>> [   78.894713]  __alloc_pages_nodemask+0x269/0x280
>>> [   78.899891]  page_frag_alloc+0x11c/0x150
>>> [   78.904471]  __netdev_alloc_skb+0xa0/0x110
>>> [   78.909277]  rx_submit+0x3b/0x2e0
>>> [   78.913256]  rx_complete+0x196/0x2d0
>>> [   78.917560]  __usb_hcd_giveback_urb+0x86/0x100
>>> [   78.922681]  xhci_giveback_urb_in_irq+0x86/0x100
>>> [   78.928769]  ? ip_rcv+0x261/0x390
>>> [   78.932739]  xhci_td_cleanup+0xe7/0x170
>>> [   78.937308]  handle_tx_event+0x297/0x1190
>>> [   78.941990]  xhci_irq+0x300/0xb80
>>> [   78.945968]  ? pciehp_isr+0x46/0x320
>>> [   78.950870]  __handle_irq_event_percpu+0x3a/0x1a0
>>> [   78.956311]  handle_irq_event_percpu+0x20/0x50
>>> [   78.961466]  handle_irq_event+0x3d/0x60
>>> [   78.965962]  handle_edge_irq+0x71/0x190
>>> [   78.970480]  handle_irq+0xa5/0x100
>>> [   78.974565]  do_IRQ+0x41/0xc0
>>> [   78.978206]  ? pagevec_move_tail_fn+0x350/0x350
>>> [   78.983412]  common_interrupt+0x96/0x96
>>
>>Unfortunatelly we are missing the most imporatant information, the
>>meminfo. We cannot tell much without it. Maybe collecting /proc/vmstat
>>during the test will tell us more.
>
>Attached the JSON format per-second vmstat records.
>It feels more readable than the raw dumps.

And here is the meminfo lines.

Thanks,
Fengguang


--fqvh44pibocj3rev
Content-Type: application/gzip
Content-Disposition: attachment; filename="meminfo.json.gz"
Content-Transfer-Encoding: base64

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

--fqvh44pibocj3rev--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
