Date: Mon, 15 Jan 2001 21:49:16 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: mmap()/VM problems in 2.4.0
In-Reply-To: <87hf30d0ar.fsf@atlas.iskon.hr>
Message-ID: <Pine.Linu.4.10.10101152142440.772-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Vlad Bolkhovitine <vladb@sw.com.sg>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15 Jan 2001, Zlatko Calusic wrote:

> "Vlad Bolkhovitine" <vladb@sw.com.sg> writes:
> 
> > Here is updated info for 2.4.1pre3:
> > 
> > Size is MB, BlkSz is Bytes, Read, Write, and Seeks are MB/sec
> > 
> > with mmap()
> > 
> >  File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
> >  Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> > ------- ------ ------- --- ----------- ----------- ----------- -----------
> >    .     1024   4096    2  1.089 1.24% 0.235 0.45% 1.118 4.11% 0.616 1.41%
> > 
> > without mmap()
> >    
> >  File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
> >  Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> > ------- ------ ------- --- ----------- ----------- ----------- -----------
> >    .     1024   4096    2  28.41 41.0% 0.547 1.15% 13.16 16.1% 0.652 1.46%
> > 
> > 
> > Mmap() performance dropped dramatically down to almost unusable level. Plus,
> > system was unusable during test: "vmstat 1" updated results every 1-2 _MINUTES_!
> > 
> 
> You need Marcelo's patch. Please apply and retest.

My box thinks quite highly of that patch fwiw, but insists that he needs
to apply Jens Axboes' blk patch first ;-)  (Not because of tiobench)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
