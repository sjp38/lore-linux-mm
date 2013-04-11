Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3622A6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:30:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1ffcce76-7e25-4ca5-b201-dedfa3e2e2b1@default>
Date: Thu, 11 Apr 2013 10:30:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
References: <1365400862-9041-1-git-send-email-minchan@kernel.org>
 <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
 <20130409012719.GB3467@blaptop> <20130409013606.GC3467@blaptop>
 <51647F94.6000907@linux.vnet.ibm.com>
In-Reply-To: <51647F94.6000907@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy fro=
m zram in-memory)
>=20
> On 04/08/2013 08:36 PM, Minchan Kim wrote:
> > On Tue, Apr 09, 2013 at 10:27:19AM +0900, Minchan Kim wrote:
> >> Hi Dan,
> >>
> >> On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
> >>>> From: Minchan Kim [mailto:minchan@kernel.org]
> >>>> Sent: Monday, April 08, 2013 12:01 AM
> >>>> Subject: [PATCH] mm: remove compressed copy from zram in-memory
> >>>
> >>> (patch removed)
> >>>
> >>>> Fragment ratio is almost same but memory consumption and compile tim=
e
> >>>> is better. I am working to add defragment function of zsmalloc.
> >>>
> >>> Hi Minchan --
> >>>
> >>> I would be very interested in your design thoughts on
> >>> how you plan to add defragmentation for zsmalloc.  In
> >>
> >> What I can say now about is only just a word "Compaction".
> >> As you know, zsmalloc has a transparent handle so we can do whatever
> >> under user. Of course, there is a tradeoff between performance
> >> and memory efficiency. I'm biased to latter for embedded usecase.
> >>
> >> And I might post it because as you know well, zsmalloc
> >
> > Incomplete sentense,
> >
> > I might not post it until promoting zsmalloc because as you know well,
> > zsmalloc/zram's all new stuffs are blocked into staging tree.
> > Even if we could add it into staging, as you know well, staging is wher=
e
> > every mm guys ignore so we end up needing another round to promote it. =
sigh.
>=20
> Yes. The lack of compaction/defragmentation support in zsmalloc has not
> been raised as an obstacle to mainline acceptance so I think we should
> wait to add new features to a yet-to-be accepted codebase.

Um, I explicitly raised as an obstacle the greatly reduced density for
zsmalloc on active workloads and on zsize distributions that skew fat.
Understanding that more deeply and hopefully fixing it is an issue,
and compaction/defragmentation is a step in that direction.

> Also, I think this feature is more important to zram than it is to
> zswap/zcache as they can do writeback to free zpages.  In other words,
> the fragmentation is a transient issue for zswap/zcache since writeback
> to the swap device is possible.

Actually, I think I demonstrated that the zpage-based writeback in
zswap makes fragmentation worse.  Zcache doesn't use zsmalloc
in part because it doesn't support pagframe writeback.  If zsmalloc
can fix this (and it may be easier to fix depending on the design
and implementation of compaction/defrag, which is why I'm asking
lots of questions), zcache may be able to make use of zsmalloc.

Lots of good discussion fodder for next week!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
