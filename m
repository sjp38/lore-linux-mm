Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AAF356B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 07:47:39 -0500 (EST)
Date: Fri, 13 Nov 2009 13:47:35 +0100 (CET)
From: Tobias Oetiker <tobi@oetiker.ch>
Subject: Re: [PATCH 0/5] Reduce GFP_ATOMIC allocation failures, candidate
 fix V3
In-Reply-To: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0911131346560.22447@wbuna.brgvxre.pu>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\\\"" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

Yesterday Mel Gorman wrote:

> Sorry for the long delay in posting another version. Testing is extremely
> time-consuming and I wasn't getting to work on this as much as I'd have liked.
>
> Changelog since V2
>   o Dropped the kswapd-quickly-notice-high-order patch. In more detailed
>     testing, it made latencies even worse as kswapd slept more on high-order
>     congestion causing order-0 direct reclaims.
>   o Added changes to how congestion_wait() works
>   o Added a number of new patches altering the behaviour of reclaim

so is there anything promissing for the order 5 allocation problems
in this set?

cheers
tobi


-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
