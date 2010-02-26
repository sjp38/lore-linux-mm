Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0536E6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 10:33:19 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Memory management woes - order 1 allocation failures
Date: Fri, 26 Feb 2010 16:33:16 +0100
References: <201002261232.28686.elendil@planet.nl> <84144f021002260601o7ab345fer86b8bec12dbfc31e@mail.gmail.com>
In-Reply-To: <84144f021002260601o7ab345fer86b8bec12dbfc31e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002261633.17437.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Friday 26 February 2010, Pekka Enberg wrote:
> > Isn't it a bit strange that cache claims so much memory that real
> > processes get into allocation failures?
>
> All of the failed allocations seem to be GFP_ATOMIC so it's not _that_
> strange.

It's still very ugly though. And I would say it should be unnecessary.

> Dunno if anything changed recently. What's the last known good kernel for
> you? 

I've not used that box very intensively in the past, but I first saw the 
allocation failure with aptitude with either .31 or .32. I would be 
extremely surprised if I could reproduce the problem with .30.
And I have done large rsyncs to the box without any problems in the past, 
but that must have been with .24 or so kernels.

It seems likely to me that it's related to all the other swap and 
allocation issues we've been seeing after .30.

Thanks,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
