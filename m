Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id C525A6B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 22:15:00 -0400 (EDT)
Received: by oica37 with SMTP id a37so111199550oic.0
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 19:15:00 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id gq13si11119495obb.82.2015.04.19.19.14.45
        for <linux-mm@kvack.org>;
        Sun, 19 Apr 2015 19:15:00 -0700 (PDT)
Message-ID: <55345756.40902@huawei.com>
Date: Mon, 20 Apr 2015 09:33:10 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com> <5531679d.4642ec0a.1beb.3569@mx.google.com>
In-Reply-To: <5531679d.4642ec0a.1beb.3569@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, yasu.ishimatsu@gmail.com

On 2015/4/18 4:05, Yasuaki Ishimatsu wrote:

> 
> Your patches will fix your issue.
> But, if BIOS reports memory first at node hot add, pgdat can
> not be initialized.
> 
> Memory hot add flows are as follows:
> 
> add_memory
>   ...
>   -> hotadd_new_pgdat()
>   ...
>   -> node_set_online(nid)
> 
> When calling hotadd_new_pgdat() for a hot added node, the node is
> offline because node_set_online() is not called yet. So if applying
> your patches, the pgdat is not initialized in this case.
> 
> Thanks,
> Yasuaki Ishimatsu
> 

Hi Yasuaki,

I'm not quite understand, when BIOS reports memory first, why pgdat
can not be initialized?
When hotadd a new node, hotadd_new_pgdat() will be called too, and
when hotadd memory to a existent node, it's no need to call hotadd_new_pgdat(),
right?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
