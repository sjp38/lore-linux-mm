Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6A7B8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:25:56 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r131-v6so1524856oie.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:25:56 -0700 (PDT)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id f10-v6si6110845otb.21.2018.09.18.05.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 05:25:55 -0700 (PDT)
Date: Tue, 18 Sep 2018 13:24:57 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC] mm/memory_hotplug: wrong node identified if memory was
 never on-lined.
Message-ID: <20180918132457.00007c48@huawei.com>
In-Reply-To: <20180918121342.GA29130@techadventures.net>
References: <20180912150218.00002cbc@huawei.com>
	<20180918121342.GA29130@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, linuxarm@huawei.com
Cc: linux-mm@kvack.org

On Tue, 18 Sep 2018 14:13:42 +0200
Oscar Salvador <osalvador@techadventures.net> wrote:

> On Wed, Sep 12, 2018 at 03:02:18PM +0100, Jonathan Cameron wrote:
> > Now I'm not sure what the preferred fix for this would be.
> > 1) Actually set the nid for each pfn during hot add rather than waiting for
> >    online.
> > 2) Modify the whole call chain to pass the nid through as we know it at the
> >    remove_memory call for hotplug cases...  
> 
> Hi Jonathan,
Hi Oscar,

> 
> I am back from vacation after four weeks, so I might still be in a bubble.
> 
> I was cleaning up unregister_mem_sect_under_nodes in [1], but I failed
> to see this.
> I think that we can pass the node down the chain.
> 
> Looking closer, we might be able to get rid of the nodemask var there,
> but I need to take a closer look.
> 
> I had a RFCv2 sent a month ago [2] to fix another problem.
Ah. Yes I hadn't made the connection that it would be doing most of what is
needed here as well. Thanks.

> That patchset, among other things, replaces the zone paramater with the nid.
> 
> I was about to send a new version of that patchset, without RFC this time, so
> if you do not mind, I could add this change in there and you can comment it.
That would be great.

Thanks,

Jonathan
> 
> What do you think?
> 
> [1] https://patchwork.kernel.org/patch/10568547/
> [2] https://patchwork.kernel.org/patch/10569085/
> 
> Thanks
