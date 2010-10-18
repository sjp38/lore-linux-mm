Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFD06B00DA
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 17:02:47 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101018123750.ef7d6d48.akpm@linux-foundation.org>
References: <20101013144044.GS30667@csn.ul.ie>
	 <20101013175205.21187.qmail@kosh.dhis.org>
	 <20101018113331.GB30667@csn.ul.ie>
	 <20101018123750.ef7d6d48.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 08:02:16 +1100
Message-ID: <1287435736.2341.8.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, pacman@kosh.dhis.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-10-18 at 12:37 -0700, Andrew Morton wrote:
> Well, you've spotted a bug so I'd say we fix it asap.
> 
> It's a bit of a shame that we lose the only known way of reproducing a
> different bug, but presumably that will come back and bite someone
> else
> one day, and we'll fix it then :(

Well, I can always revert that and run some experiments here, provided I
can reproduce the problem at all ...

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
