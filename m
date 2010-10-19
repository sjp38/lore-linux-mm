Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B2E496B009C
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 16:59:13 -0400 (EDT)
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20101019181021.22456.qmail@kosh.dhis.org>
References: <20101019181021.22456.qmail@kosh.dhis.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 07:58:43 +1100
Message-ID: <1287521923.2198.2.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pacman@kosh.dhis.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-10-19 at 13:10 -0500, pacman@kosh.dhis.org wrote:
> 
> So what type of driver, firmware, or hardware bug puts a 16-bit 1000Hz
> timer
> in memory, and does it in little-endian instead of the CPU's native
> byte
> order? And why does it stop doing it some time during the early init
> scripts,
> shortly after the root filesystem fsck?
> 
> I have not yet attempted to repeat the experiment. If it is
> repeatable, I'll
> probe more deeply into those init scripts later. I'm looking hard at
> /etc/rcS.d/S11hwclock.sh 

Stinks of USB...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
