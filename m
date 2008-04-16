Date: Wed, 16 Apr 2008 21:16:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] Verify the page links and memory model
Message-ID: <20080416201651.GD13968@csn.ul.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie> <20080416135138.1346.87095.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0804161211140.14635@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804161211140.14635@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (16/04/08 12:12), Christoph Lameter didst pronounce:
> On Wed, 16 Apr 2008, Mel Gorman wrote:
> 
> > +		FLAGS_RESERVED);
> 
> FLAGS_RESERVED no longer exists in mm. Its dynamically calculated.
> 
> It may be useful to print out NR_PAGEFLAGS instead and show the area in 
> the middle of page flags that is left unused and that may be used by 
> arches such as sparc64.
> 

That's a good point. I'll do that on a version I rebase to -mm. V2 will
still be based on mainline.

Thanks.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
