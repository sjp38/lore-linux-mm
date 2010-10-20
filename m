Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C036B6B00A6
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 06:36:24 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101020032345.5240.qmail@kosh.dhis.org>
References: <20101020032345.5240.qmail@kosh.dhis.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 21:32:16 +1100
Message-ID: <1287570736.2198.19.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: Segher Boessenkool <segher@kernel.crashing.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-10-19 at 22:23 -0500, pacman@kosh.dhis.org wrote:
> The diff fragment above applied inside prom_close_stdin, but there are
> some
> prom_printf calls after prom_close_stdin. Calling prom_printf after
> closing
> stdout sounds like it could be bad. If I moved it down below all the
> prom_printf's, it would be after the "quiesce" call. Would that be
> acceptable
> (or even interesting as an experiment)? Does a close need a quiesce
> after it?

Just try :-) "quiesce" is something that afaik only apple ever
implemented anyways. It uses hooks inside their OF to shut down all
drivers that do bus master (among other HW sanitization tasks).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
