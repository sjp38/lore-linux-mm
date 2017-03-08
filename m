Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 590336B03B8
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:59:05 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r141so40326111ita.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:59:05 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id v7si4217587iod.13.2017.03.08.07.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:59:04 -0800 (PST)
Date: Wed, 8 Mar 2017 09:58:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/6] Slab Fragmentation Reduction V16
In-Reply-To: <20170308143411.GC11034@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1703080955180.16208@east.gentwo.org>
References: <20170307212429.044249411@linux.com> <20170308143411.GC11034@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

On Wed, 8 Mar 2017, Michal Hocko wrote:

> JFTR the previous version was posted here: https://lwn.net/Articles/371892/
> and Dave had some concerns https://lkml.org/lkml/2010/2/8/329 which led
> to a different approach and design of the slab shrinking
> https://lkml.org/lkml/2010/2/8/329.
>
> I haven't looked at this series yet but has those concerns been
> addressed/considered?

Well yes this has been discussed for a couple of years. The basic approach
is not only needed for the file systems (like what Chinner was focusing
on) but in general for slab caches. The objection was regarding the
integration into the slab reclaim logic in vmscan.c and the filesystem
reclaim in general.

Dave and Matthew were at linux.conf.au and we agreed to first try it with
the radix tree and then generalize from there.  The reclaim logic
was a bit hacky and we will have to find some better way to
integrate this.

There is a video on youtube capturing the discussion (My talk on movable
kernel objects).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
