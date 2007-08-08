Date: Wed, 8 Aug 2007 22:06:37 +0100
Subject: Re: [PATCH 1/3] Use zonelists instead of zones when direct reclaiming pages
Message-ID: <20070808210637.GA2441@skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie> <20070808161524.32320.87008.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708081037450.12652@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708081037450.12652@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/08/07 10:38), Christoph Lameter didst pronounce:
> Good idea. Maybe it could be taken further by passing the zonelist also 
> into shrink_zones()?
> 

Yeah, it could. It's a cleanup even though it doesn't simplify the
iterator. When the patch was done first, it was because multiple
iterators were needed to go through the zones in the zonelist. With this
cleanup, only one iterator was needed but it could be carried through
for consistency.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
