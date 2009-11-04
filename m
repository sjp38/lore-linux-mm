Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6F4B76B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 21:06:04 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
Date: Wed, 4 Nov 2009 03:05:55 +0100
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911040101.50194.elendil@planet.nl> <20091104011811.GG22046@csn.ul.ie>
In-Reply-To: <20091104011811.GG22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200911040305.59352.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 04 November 2009, Mel Gorman wrote:
> > If you'd like me to test with the congestion_wait() revert on top of
> > this for comparison, please let me know.
>
> No, there is resistance to rolling back the congestion_wait() changes

I've never promoted the revert as a solution. It just shows the cause of a 
regression.

> from what I gather because they were introduced for sane reasons. The
> consequence is just that the reliability of high-order atomics are
> impacted because more processes are making forward progress where
> previously they would have waited until kswapd had done work. Your
> driver has already been fixed in this regard and maybe it's a case that
> the other atomic users simply have to be fixed to "not do that".

The problem is that although my driver has been fixed so that it no longer 
causes the SKB allocation errors, the also rather serious behavior change 
where due to swapping my 3rd gitk takes up to twice as long to load with 
desktop freezes of up 45 seconds or so is still there.

Although that's somewhat separate from the issue that started this whole 
investigation, I still feel that should be sorted out as well.

The congestion_wait() change, even if theoretically valid, introduced a 
very real regression IMO. Such long desktop freezes during swapping should 
be avoided; .30 and earlier simply behaved a whole lot better in the same 
situation.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
