Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <linux-mm@kvack.org>; Tue, 15 Nov 2005 15:04:51 -0800
Date: Tue, 15 Nov 2005 15:04:51 -0800 (PST)
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/5] Light Fragmentation Avoidance V20: 001_antidefrag_flags
In-Reply-To: <20051115150054.606ce0df.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0511151503290.28745@shark.he.net>
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie>
 <20051115164952.21980.3852.sendpatchset@skynet.csn.ul.ie>
 <20051115150054.606ce0df.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Paul Jackson wrote:

> Mel wrote:
> >  #define __GFP_VALID	((__force gfp_t)0x80000000u) /* valid GFP flags */
> >
> > +/*
> > + * Allocation type modifier
> > + * __GFP_EASYRCLM: Easily reclaimed pages like userspace or buffer pages
> > + */
> > +#define __GFP_EASYRCLM   0x80000u  /* User and other easily reclaimed pages */
> > +
>
> How about fitting the style (casts, just one line) of the other flags,
> so that these added six lines become instead just the one line:
>
>    #define __GFP_EASYRCLM   ((__force gfp_t)0x80000u)  /* easily reclaimed pages */
>
> (Yeah - it was probably me that asked for -more- comments sometime in
> the past - consistency is not my strong suit ;).

Conversely, if you are going to go to the effort of lots of docs,
please do it in kernel-doc format.
  Documentation/kernel-doc-nano-HOWTO.txt

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
