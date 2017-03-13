Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4DA06B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:16:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v190so12912347wme.0
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 02:16:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m73si10098080wmg.71.2017.03.13.02.16.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 02:16:37 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:16:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 0/6] Slab Fragmentation Reduction V16
Message-ID: <20170313091635.GE31518@dhcp22.suse.cz>
References: <20170307212429.044249411@linux.com>
 <20170308143411.GC11034@dhcp22.suse.cz>
 <alpine.DEB.2.20.1703080955180.16208@east.gentwo.org>
 <20170313091515.GD31518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313091515.GD31518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

On Mon 13-03-17 10:15:15, Michal Hocko wrote:
> On Wed 08-03-17 09:58:58, Cristopher Lameter wrote:
> > On Wed, 8 Mar 2017, Michal Hocko wrote:
> > 
> > > JFTR the previous version was posted here: https://lwn.net/Articles/371892/
> > > and Dave had some concerns https://lkml.org/lkml/2010/2/8/329 which led
> > > to a different approach and design of the slab shrinking
> > > https://lkml.org/lkml/2010/2/8/329.
> > >
> > > I haven't looked at this series yet but has those concerns been
> > > addressed/considered?
> > 
> > Well yes this has been discussed for a couple of years. The basic approach
> > is not only needed for the file systems (like what Chinner was focusing
> > on) but in general for slab caches. The objection was regarding the
> > integration into the slab reclaim logic in vmscan.c and the filesystem
> > reclaim in general.
> > 
> > Dave and Matthew were at linux.conf.au and we agreed to first try it with
> > the radix tree and then generalize from there.  The reclaim logic
> > was a bit hacky and we will have to find some better way to
> > integrate this.
> > 
> > There is a video on youtube capturing the discussion (My talk on movable
> > kernel objects).
> 
> Hmm, OK. There seems to be a slot to discuss this at LSFMM this year so
> I hope we can discuss your proposal there.

Btw. it would be great if you could summarize the discussion you had at
LCA here as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
