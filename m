Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E26546B0032
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 22:11:07 -0400 (EDT)
Received: by qgej70 with SMTP id j70so46482480qge.2
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 19:11:07 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id fm10si18378205qcb.45.2015.04.19.19.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Apr 2015 19:11:07 -0700 (PDT)
Received: by qgfi89 with SMTP id i89so46450337qgf.1
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 19:11:07 -0700 (PDT)
Message-ID: <5534603a.36208c0a.4784.6286@mx.google.com>
Date: Sun, 19 Apr 2015 19:11:06 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 1/2 V2] memory-hotplug: fix BUG_ON in move_freepages()
References: <5530E578.9070505@huawei.com>
	<5531679d.4642ec0a.1beb.3569@mx.google.com>
	<55345756.40902@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


> When hot adding memory and creating new node, the node is offline.
> And after calling node_set_online(), the node becomes online.
> 
> Oh, sorry. I misread your ptaches.
> 

Please ignore it...

Thanks,
Yasuaki Ishimatsu

On 
Yasuaki Ishimatsu <yasu.isimatu@gmail.com> wrote:

> 
> When hot adding memory and creating new node, the node is offline.
> And after calling node_set_online(), the node becomes online.
> 
> Oh, sorry. I misread your ptaches.
> 
> Thanks,
> Yasuaki Ishimatsu
> 
> On Mon, 20 Apr 2015 09:33:10 +0800
> Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
> > On 2015/4/18 4:05, Yasuaki Ishimatsu wrote:
> > 
> > > 
> > > Your patches will fix your issue.
> > > But, if BIOS reports memory first at node hot add, pgdat can
> > > not be initialized.
> > > 
> > > Memory hot add flows are as follows:
> > > 
> > > add_memory
> > >   ...
> > >   -> hotadd_new_pgdat()
> > >   ...
> > >   -> node_set_online(nid)
> > > 
> > > When calling hotadd_new_pgdat() for a hot added node, the node is
> > > offline because node_set_online() is not called yet. So if applying
> > > your patches, the pgdat is not initialized in this case.
> > > 
> > > Thanks,
> > > Yasuaki Ishimatsu
> > > 
> > 
> > Hi Yasuaki,
> > 
> > I'm not quite understand, when BIOS reports memory first, why pgdat
> > can not be initialized?
> > When hotadd a new node, hotadd_new_pgdat() will be called too, and
> > when hotadd memory to a existent node, it's no need to call hotadd_new_pgdat(),
> > right?
> > 
> > Thanks,
> > Xishi Qiu
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
