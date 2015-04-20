Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0A76B0038
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:15:23 -0400 (EDT)
Received: by ykft189 with SMTP id t189so16414698ykf.1
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:15:22 -0700 (PDT)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com. [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id x49si9766276yha.209.2015.04.19.20.15.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Apr 2015 20:15:22 -0700 (PDT)
Received: by yhda23 with SMTP id a23so15820973yhd.2
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 20:15:22 -0700 (PDT)
Message-ID: <55346f49.8bc6ec0a.5fe5.ffffcdac@mx.google.com>
Date: Sun, 19 Apr 2015 20:15:21 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
In-Reply-To: <55346B99.2060602@huawei.com>
References: <5530E578.9070505@huawei.com>
	<5531679d.4642ec0a.1beb.3569@mx.google.com>
	<55345756.40902@huawei.com>
	<5534603a.36208c0a.4784.6286@mx.google.com>
	<55345FC4.4070404@cn.fujitsu.com>
	<55346B99.2060602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Mon, 20 Apr 2015 10:59:37 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> On 2015/4/20 10:09, Gu Zheng wrote:
> 
> > Hi Ishimatsu, Xishi,
> > 
> > On 04/20/2015 10:11 AM, Yasuaki Ishimatsu wrote:
> > 
> >>
> >>> When hot adding memory and creating new node, the node is offline.
> >>> And after calling node_set_online(), the node becomes online.
> >>>
> >>> Oh, sorry. I misread your ptaches.
> >>>
> >>
> >> Please ignore it...
> > 
> > Seems also a misread to me.
> > I clear it (my worry) here:
> > If we set the node size to 0 here, it may hidden more things than we experted.
> > All the init chunks around with the size (spanned/present/managed...) will
> > be non-sense, and the user/caller will not get a summary of the hot added node
> > because of the changes here.
> > I am not sure the worry is necessary, please correct me if I missing something.
> > 
> > Regards,
> > Gu
> > 
> 
> Hi Gu,
> 
> My patch is just set size to 0 when hotadd a node(old or new). I know your worry,
> but I think it is not necessary.
> 

> When we calculate the size, it uses "arch_zone_lowest_possible_pfn[]" and "memblock",
> and they are both from boot time. If we hotadd a new node, the calculated size is
> 0 too. When add momery, __add_zone() will grow the size and start.

If hot adding new node, you are right. But if hot removing a memory which
is presented at boot time, memblock of the memory range is not deleted.
So when hot adding the memory, the calculated size does not become 0.

Thanks,
Yasuaki Ishimatsu

> 
> Thanks,
> Xishi Qiu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
