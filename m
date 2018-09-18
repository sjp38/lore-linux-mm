Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B24B88E0002
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:13:46 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id z2-v6so914019wmi.7
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:13:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor7182183wmb.7.2018.09.18.05.13.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 05:13:44 -0700 (PDT)
Date: Tue, 18 Sep 2018 14:13:42 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] mm/memory_hotplug: wrong node identified if memory was
 never on-lined.
Message-ID: <20180918121342.GA29130@techadventures.net>
References: <20180912150218.00002cbc@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912150218.00002cbc@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-mm@kvack.org, linuxarm@huawei.com

On Wed, Sep 12, 2018 at 03:02:18PM +0100, Jonathan Cameron wrote:
> Now I'm not sure what the preferred fix for this would be.
> 1) Actually set the nid for each pfn during hot add rather than waiting for
>    online.
> 2) Modify the whole call chain to pass the nid through as we know it at the
>    remove_memory call for hotplug cases...

Hi Jonathan,

I am back from vacation after four weeks, so I might still be in a bubble.

I was cleaning up unregister_mem_sect_under_nodes in [1], but I failed
to see this.
I think that we can pass the node down the chain.

Looking closer, we might be able to get rid of the nodemask var there,
but I need to take a closer look.

I had a RFCv2 sent a month ago [2] to fix another problem.
That patchset, among other things, replaces the zone paramater with the nid.

I was about to send a new version of that patchset, without RFC this time, so
if you do not mind, I could add this change in there and you can comment it.

What do you think?

[1] https://patchwork.kernel.org/patch/10568547/
[2] https://patchwork.kernel.org/patch/10569085/

Thanks
-- 
Oscar Salvador
SUSE L3
