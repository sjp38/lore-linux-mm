Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A8CC6B007B
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 04:04:27 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate fix V3
Date: Fri, 13 Nov 2009 10:04:21 +0100
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200911131004.25293.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thursday 12 November 2009, Mel Gorman wrote:
> Changelog since V2
>   o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
>     testing, it made latencies even worse as kswapd slept more on
>     high-order congestion causing order-0 direct reclaims.
>   o Added changes to how congestion_wait() works
>   o Added a number of new patches altering the behaviour of reclaim

I have tested this series on top of .32-rc7. First impression is that it 
does seem to improve my test case, but does not yet completely solve it.

My last gitk instance now loads more smoothly for most of the time it takes 
to complete, but I still see a choke point where things freeze for a while 
and where I get SKB allocation errors from my wireless.
However, that choke point does seem to happen later and to be shorter than 
without the patches.

I'll try to do additional tests (with .31). If you'd like me to run this 
set with your instrumentation patch for congestion_wait, then please let 
me know.

Chris Mason's analysis regarding dm-crypt workqueues in reply to your other 
mail looks very interesting.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
