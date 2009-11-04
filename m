Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A501B6B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 15:57:27 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
Date: Wed, 4 Nov 2009 21:57:21 +0100
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911040305.59352.elendil@planet.nl> <20091104154853.GM22046@csn.ul.ie>
In-Reply-To: <20091104154853.GM22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200911042157.25020.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 04 November 2009, Mel Gorman wrote:
> Agreed. I'll start from scratch again trying to reproduce what you're
> seeing locally. I'll try breaking my network card so that it's making
> high-order atomics and see where I get. Machines that were previously
> tied up are now free so I might have a better chance.

Hmmm. IMO you're looking at this from the wrong side. You don't need to 
break your network card because the SKB problems are only the *result* of 
the change, not the *cause*.

I can reproduce the desktop freeze just as easily when I'm using wired 
(e1000e) networking and when I'm not streaming music at all, but just 
loading that 3rd gitk instance.

So it's not
  "I get a desktop freeze because of high order allocations from wireless
   during swapping",
but
  "during very heavy swapping on a system with an encrypted LMV volume
   group containing (encrypted) fs and (encrytpted) swap, the swapping
   gets into some semi-stalled state *causing* a long desktop freeze
   and, if there also happens to be some process trying higher order
   allocations, failures of those allocations".

I have tried to indicate this in the past, but it may have gotten lost in 
the complexity of the issue.

An important clue is still IMO that during the first part of the freezes 
there is very little disk activity for a long time. Why would that be when 
the system is supposed to be swapping like hell?

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
