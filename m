Message-ID: <433B8E76.9080005@yahoo.com.au>
Date: Thu, 29 Sep 2005 16:49:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] Reset the high water marks in CPUs pcp list
References: <20050928105009.B29282@unix-os.sc.intel.com>  <Pine.LNX.4.62.0509281259550.14892@schroedinger.engr.sgi.com>  <1127939185.5046.17.camel@akash.sc.intel.com>  <Pine.LNX.4.62.0509281408480.15213@schroedinger.engr.sgi.com> <1127943168.5046.39.camel@akash.sc.intel.com> <Pine.LNX.4.62.0509281455310.15902@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509281455310.15902@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Rohit Seth <rohit.seth@intel.com>, akpm@osdl.org, linux-mm@kvack.org, Mattia Dongili <malattia@linux.it>, linux-kernel@vger.kernel.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>
>I know that Jack and Nick did something with those counts to insure that 
>page coloring effects are avoided. Would you comment?
>
>

The 'batch' argument to setup_pageset should be clamped to a power
of 2 minus 1 (ie. 15, 31, etc), which was found to avoid the worst
of the colouring problems.

pcp->high of the hotlist IMO should have been reduced to 4 anyway
after its pcp->low was reduced from 2 to 0.

I don't see that there would be any problems with playing with the
->high and ->low numbers so long as they are a reasonable multiple
of batch, however I would question the merit of setting the high
watermark of the cold queue to ->batch + 1 (should really stay at
2*batch IMO).

Nick


Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
