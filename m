Date: Tue, 16 Jan 2001 08:06:58 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: mmap()/VM problems in 2.4.0
In-Reply-To: <3A63ED75.53094939@sw.com.sg>
Message-ID: <Pine.Linu.4.10.10101160803390.1021-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vlad Bolkhovitine <vladb@sw.com.sg>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2001, Vlad Bolkhovitine wrote:

> > My box thinks quite highly of that patch fwiw, but insists that he needs
> > to apply Jens Axboes' blk patch first ;-)  (Not because of tiobench)
> 
> New data:
> 
> 2.4.1pre3 + Marcelo's patch
> 
>        File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
> Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> ------- ------ ------- --- ----------- ----------- ----------- -----------
>    .     1024   4096    2  12.68 9.23% 0.497 0.92% 10.57 15.3% 0.594 1.44%
> 
> The same performance level as for 2.4.0. No improvement.

I was refering to the stalls.. not throughput.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
