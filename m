Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C96346B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 22:26:54 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so3493032wgg.7
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 19:26:54 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id eb7si6087770wib.80.2014.08.06.19.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 Aug 2014 19:26:53 -0700 (PDT)
Date: Wed, 6 Aug 2014 22:26:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm-memcontrol-rewrite-charge-api.patch and
 mm-memcontrol-rewrite-uncharge-api.patch
Message-ID: <20140807022648.GA30560@cmpxchg.org>
References: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Wed, Aug 06, 2014 at 01:59:14PM -0700, Andrew Morton wrote:
> 
> Do we feel these are ready for merging?
> 
> I'll send along the consolidated patches for eyeballs.

I just went over them again, as well as over the individual fixes.
The uncharge-from-irq-context was a more fundamental fix-up, as was
getting migration from fuse splicing right, but aside from that I
think the fallout was fairly mild and seems to have settled; the last
bug fix is from two weeks ago.  Given how much this series reduces the
burden memcg puts on users and maintainers, I think it should go in.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
