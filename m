Date: Thu, 6 Oct 2005 16:15:15 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] Fragmentation Avoidance V16: 001_antidefrag_flags
In-Reply-To: <20051006081128.62c9ab1f.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0510061614370.1255@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
 <20051005144552.11796.52857.sendpatchset@skynet.csn.ul.ie>
 <20051006081128.62c9ab1f.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, jschopp@austin.ibm.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, 6 Oct 2005, Paul Jackson wrote:

> Mel wrote:
> > +/* Allocation type modifiers, group together if possible */
>
> Isn't that "if possible" bogus.  I thought these two bits
> _had_ to be grouped together, at least with the current code.
>
> What happened to the comment that Joel added to gpl.h:
>

My bad. I missed it while resyncing with Joel. I have it in now.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
