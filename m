Date: Fri, 23 Jun 2000 20:03:56 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
In-Reply-To: <Pine.LNX.4.21.0006231956200.1280-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006232002320.1280-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2000, Andrea Arcangeli wrote:

>On Fri, 23 Jun 2000, Jamie Lokier wrote:
>
>>Quite.  So __cacheline_aligned_in_smp is not sufficient to ensure the
>>array doesn't share cache lines with another variable.
>
>Of course, it does only half of the work, you need it here:
>
>	gfpmask_zone_t node_gfpmask_zone[NR_GFPINDEX] ____cacheline_aligned_in_smp;

btw, I'm not suggesting to add the above (I only wanted to show its
usage).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
