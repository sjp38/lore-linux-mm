Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2100E6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:27:22 -0400 (EDT)
Date: Tue, 9 Apr 2013 10:27:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
Message-ID: <20130409012719.GB3467@blaptop>
References: <1365400862-9041-1-git-send-email-minchan@kernel.org>
 <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

Hi Dan,

On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
> > From: Minchan Kim [mailto:minchan@kernel.org]
> > Sent: Monday, April 08, 2013 12:01 AM
> > Subject: [PATCH] mm: remove compressed copy from zram in-memory
> 
> (patch removed)
> 
> > Fragment ratio is almost same but memory consumption and compile time
> > is better. I am working to add defragment function of zsmalloc.
> 
> Hi Minchan --
> 
> I would be very interested in your design thoughts on
> how you plan to add defragmentation for zsmalloc.  In

What I can say now about is only just a word "Compaction".
As you know, zsmalloc has a transparent handle so we can do whatever
under user. Of course, there is a tradeoff between performance 
and memory efficiency. I'm biased to latter for embedded usecase.

And I might post it because as you know well, zsmalloc

> particular, I am wondering if your design will also
> handle the requirements for zcache (especially for
> cleancache pages) and perhaps also for ramster.

I don't know requirements for cleancache pages but compaction is
general as you know well so I expect you can get a benefit from it
if you are concern on memory efficiency but not sure it's valuable
to compact cleancache pages for getting more slot in RAM.
Sometime, just discarding would be much better, IMHO.

> 
> In https://lkml.org/lkml/2013/3/27/501 I suggested it
> would be good to work together on a common design, but
> you didn't reply.  Are you thinking that zsmalloc

I saw the thread but explicit agreement is really matter?
I believe everybody want it although they didn't reply. :)

You can make the design/post it or prototyping/post it.
If there are some conflit with something in my brain,
I will be happy to feedback. :)

Anyway, I think my above statement "COMPACTION" would be enough to
express my current thought to avoid duplicated work and you can catch up.

I will get around to it after LSF/MM.

> improvements should focus only on zram, in which case

Just focusing zsmalloc.

> we may -- and possibly should -- end up with a different
> allocator for frontswap-based/cleancache-based compression
> in zcache (and possibly zswap)?

> 
> I'm just trying to determine if I should proceed separately
> with my design (with Bob Liu, who expressed interest) or if
> it would be beneficial to work together.

Just posting and if it affects zsmalloc/zram/zswap and goes the way
I don't want, I will involve the discussion because our product uses
zram heavily and consider zswap, too.

I really appreciate your enthusiastic collaboration model to find
optimal solution!

> 
> Thanks,
> Dan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
