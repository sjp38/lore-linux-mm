Message-ID: <3A63ED75.53094939@sw.com.sg>
Date: Tue, 16 Jan 2001 14:43:01 +0800
Content-Class: urn:content-classes:message
From: "Vlad Bolkhovitine" <vladb@sw.com.sg>
MIME-Version: 1.0
Subject: Re: mmap()/VM problems in 2.4.0
References: <Pine.Linu.4.10.10101152142440.772-100000@mikeg.weiden.de>
Content-Type: text/plain;
	charset="koi8-r"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Galbraith wrote:
> 
> On 15 Jan 2001, Zlatko Calusic wrote:
> 
> > "Vlad Bolkhovitine" <vladb@sw.com.sg> writes:
> >
> > > Here is updated info for 2.4.1pre3:
> > >
> > > Size is MB, BlkSz is Bytes, Read, Write, and Seeks are MB/sec
> > >
> > > with mmap()
> > >
> > >  File   Block  Num          Seq Read    Rand Read   Seq Write  Rand Write
> > >  Dir    Size   Size    Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
> > > ------- ------ ------- --- ----------- ----------- ----------- -----------
> > >    .     1024   4096    2  1.089 1.24% 0.235 0.45% 1.118 4.11% 0.616 1.41%
> > >
[...]
> > > Mmap() performance dropped dramatically down to almost unusable level. Plus,
> > > system was unusable during test: "vmstat 1" updated results every 1-2 _MINUTES_!
> > >
> >
> > You need Marcelo's patch. Please apply and retest.
> 
> My box thinks quite highly of that patch fwiw, but insists that he needs
> to apply Jens Axboes' blk patch first ;-)  (Not because of tiobench)

New data:

2.4.1pre3 + Marcelo's patch

       File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
------- ------ ------- --- ----------- ----------- ----------- -----------
   .     1024   4096    2  12.68 9.23% 0.497 0.92% 10.57 15.3% 0.594 1.44%

The same performance level as for 2.4.0. No improvement.

2.4.1pre3 + Marcelo's patch + Jens Axboes' blk-13B patch 

         File   Block  Num  Seq Read    Rand Read   Seq Write  Rand Write
Dir    Size   Size   Thr Rate (CPU%) Rate (CPU%) Rate (CPU%) Rate (CPU%)
------- ------ ------- --- ----------- ----------- ----------- -----------
   .     1024   4096    2  12.47 10.0% 0.504 1.13% 9.998 16.5% 0.735 2.21%

No significant difference, just noise. IMHO, it is expected, since 2 threads
simply aren't enough to launch blk patch's mechanisms

>         -Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
