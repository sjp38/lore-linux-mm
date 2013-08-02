Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 93B3D6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 17:36:11 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id hi8so998330wib.9
        for <linux-mm@kvack.org>; Fri, 02 Aug 2013 14:36:10 -0700 (PDT)
Date: Fri, 2 Aug 2013 23:36:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler
 optimization
Message-ID: <20130802213607.GA4742@dhcp22.suse.cz>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130802162722.GA29220@dhcp22.suse.cz>
 <20130802204710.GX715@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802204710.GX715@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri 02-08-13 16:47:10, Johannes Weiner wrote:
> On Fri, Aug 02, 2013 at 06:27:22PM +0200, Michal Hocko wrote:
> > On Fri 02-08-13 11:07:56, Joonsoo Kim wrote:
> > > We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
> > > in slow path. For making fast path more faster, add likely macro to
> > > help compiler optimization.
> > 
> > The code is different in mmotm tree (see mm: page_alloc: rearrange
> > watermark checking in get_page_from_freelist)
> 
> Yes, please rebase this on top.
> 
> > Besides that, make sure you provide numbers which prove your claims
> > about performance optimizations.
> 
> Isn't that a bit overkill?  We know it's a likely path (we would
> deadlock constantly if a sizable portion of allocations were to ignore
> the watermarks).  Does he have to justify that likely in general makes
> sense?

That was more a generic comment. If there is a claim that something
would be faster it would be nice to back that claim by some numbers
(e.g. smaller hot path).

In this particular case, unlikely(alloc_flags & ALLOC_NO_WATERMARKS)
doesn't make any change to the generated code with gcc 4.8.1 resp.
4.3.4 I have here.
Maybe other versions of gcc would benefit from the hint but changelog
didn't tell us. I wouldn't add the anotation if it doesn't make any
difference for the resulting code.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
