Date: Sun, 16 Oct 2005 19:03:27 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Fragmentation Avoidance V17
In-Reply-To: <20051016105346.01c79929.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0510161902370.9492@skynet>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
 <20051015195213.44e0dabb.pj@sgi.com> <Pine.LNX.4.58.0510161255570.32005@skynet>
 <20051016105346.01c79929.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, jschopp@austin.ibm.com, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sun, 16 Oct 2005, Paul Jackson wrote:

> Mel wrote:
> > I would be happy with __GFP_USERRCLM but __GFP_EASYRCLM may be more
> > obvious?
>
> I would be delighted with either one.  Yes, __GFP_EASYRCLM is more obvious.
>

__GFP_EASYRCLM it is then unless someone has an objection. For
consistency, RCLM_USER will change to RCLM_EASY as well. Changing one and
not the other makes no sense to me.

>

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
