Date: Tue, 12 Jul 2005 13:29:40 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
Message-Id: <20050712132940.148a9490.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.58.0507121353470.32323@skynet>
References: <1121101013.15095.19.camel@localhost>
	<42D2AE0F.8020809@austin.ibm.com>
	<20050711195540.681182d0.pj@sgi.com>
	<Pine.LNX.4.58.0507121353470.32323@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel wrote:
> Joel, when merging the patches, there is one hack you need to watch out
> for. It is important for performance reasons but it is 100% obvious
> either.

I suspect you meant "it is _not_ 100% obvious" ...

Is there someway that the gfp.h changes could be reworked to make it
100% obvious that these two bits are not separate and independent
bits, but rather are a two bit field, counting an index from 0 to 3?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
