Date: Wed, 13 Jul 2005 12:15:30 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
In-Reply-To: <20050712132940.148a9490.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0507130815420.1174@skynet>
References: <1121101013.15095.19.camel@localhost> <42D2AE0F.8020809@austin.ibm.com>
 <20050711195540.681182d0.pj@sgi.com> <Pine.LNX.4.58.0507121353470.32323@skynet>
 <20050712132940.148a9490.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jul 2005, Paul Jackson wrote:

> Mel wrote:
> > Joel, when merging the patches, there is one hack you need to watch out
> > for. It is important for performance reasons but it is 100% obvious
> > either.
>
> I suspect you meant "it is _not_ 100% obvious" ...

Sorry, yes, it is not 100% obvious

> Is there someway that the gfp.h changes could be reworked to make it
> 100% obvious that these two bits are not separate and independent
> bits, but rather are a two bit field, counting an index from 0 to 3?
>

Well, what would people feel is obvious? I will always think it is clear
as I am the source of the confusion.

The two flags are not a two bit field as such, they just get treated as
that to save a few cycles. It could also be done with something like;

index = (!!(gfp_flags & __GFP_KERNRCLM) << 1) || (!!(gfp_flags & __GFP_USERRCLM))

(untested) which means if the bits change position or value, the code
won't care. This is a slightly more expensive, but possibly clearer way to
do things.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
