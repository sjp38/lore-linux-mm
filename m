Date: Sat, 28 Jul 2001 10:40:30 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072805183900.00293@starship>
Message-ID: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: linux-mm@kvack.org, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>


On Sat, 28 Jul 2001, Daniel Phillips wrote:

> On Saturday 28 July 2001 01:43, Roger Larsson wrote:
> > Hi again,
> >
> > It might be variations in dbench - but I am not sure since I run
> > the same script each time.
> 
> I believe I can reproduce the effect here, even with dbench 2.  So the 
> next two steps:
> 
>   1) Get some sleep
>   2) Find out why

I would suggest getting the SAR patch to measure amount of successful
request merges and compare that between the different kernels.

It sounds like the test being done is doing a lot of contiguous IO, so
increasing readahead also increases throughtput.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
