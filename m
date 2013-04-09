Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 521826B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 16:38:05 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3cc0fdea-7064-4b95-bbee-30c6448f0487@default>
Date: Tue, 9 Apr 2013 13:37:47 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
References: <1365400862-9041-1-git-send-email-minchan@kernel.org>
 <f3c8ef05-a880-47db-86dd-156038fc7d0f@default>
 <20130409012719.GB3467@blaptop> <20130409013606.GC3467@blaptop>
In-Reply-To: <20130409013606.GC3467@blaptop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy fro=
m zram in-memory)
>=20
> On Tue, Apr 09, 2013 at 10:27:19AM +0900, Minchan Kim wrote:
> > Hi Dan,
> >
> > On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
> > > > From: Minchan Kim [mailto:minchan@kernel.org]
> > > > Sent: Monday, April 08, 2013 12:01 AM
> > > > Subject: [PATCH] mm: remove compressed copy from zram in-memory
> > >
> > > (patch removed)
> > >
> > > > Fragment ratio is almost same but memory consumption and compile ti=
me
> > > > is better. I am working to add defragment function of zsmalloc.
> > >
> > > Hi Minchan --
> > >
> > > I would be very interested in your design thoughts on
> > > how you plan to add defragmentation for zsmalloc.  In
> >
> > What I can say now about is only just a word "Compaction".
> > As you know, zsmalloc has a transparent handle so we can do whatever
> > under user. Of course, there is a tradeoff between performance
> > and memory efficiency. I'm biased to latter for embedded usecase.
> >
> > And I might post it because as you know well, zsmalloc
>=20
> Incomplete sentense,
>=20
> I might not post it until promoting zsmalloc because as you know well,
> zsmalloc/zram's all new stuffs are blocked into staging tree.
> Even if we could add it into staging, as you know well, staging is where
> every mm guys ignore so we end up needing another round to promote it. si=
gh.
>=20
> I hope it gets better after LSF/MM.

If zsmalloc is moving in the direction of supporting only zram,
why should it be promoted into mm, or even lib?  Why not promote
zram into drivers and put zsmalloc.c in the same directory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
