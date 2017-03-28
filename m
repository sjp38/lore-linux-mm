Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6AA76B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:58:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o70so50597471wrb.11
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:58:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b73si2498494wmf.0.2017.03.28.00.58.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 00:58:09 -0700 (PDT)
Date: Tue, 28 Mar 2017 09:58:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory hotplug and force_remove
Message-ID: <20170328075808.GB18241@dhcp22.suse.cz>
References: <20170320192938.GA11363@dhcp22.suse.cz>
 <2735706.OR0SQDpVy6@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2735706.OR0SQDpVy6@aspire.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Toshi Kani <toshi.kani@hp.com>, Jiri Kosina <jkosina@suse.cz>, joeyli <jlee@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Mon 20-03-17 22:24:42, Rafael J. Wysocki wrote:
> On Monday, March 20, 2017 03:29:39 PM Michal Hocko wrote:
> > Hi Rafael,
> 
> Hi,
> 
> > we have been chasing the following BUG() triggering during the memory
> > hotremove (remove_memory):
> > 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> > 				check_memblock_offlined_cb);
> > 	if (ret)
> > 		BUG();
> > 
> > and it took a while to learn that the issue is caused by
> > /sys/firmware/acpi/hotplug/force_remove being enabled. I was really
> > surprised to see such an option because at least for the memory hotplug
> > it cannot work at all. Memory hotplug fails when the memory is still
> > in use. Even if we do not BUG() here enforcing the hotplug operation
> > will lead to problematic behavior later like crash or a silent memory
> > corruption if the memory gets onlined back and reused by somebody else.
> > 
> > I am wondering what was the motivation for introducing this behavior and
> > whether there is a way to disallow it for memory hotplug. Or maybe drop
> > it completely. What would break in such a case?
> 
> Honestly, I don't remember from the top of my head and I haven't looked at
> that code for several months.
> 
> I need some time to recall that.

Did you have any chance to look into this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
