Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E4DEB6B005A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 03:53:56 -0400 (EDT)
Date: Wed, 15 Jul 2009 04:31:36 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: What to do with this message (2.6.30.1) ?
In-Reply-To: <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.0907150430080.4475@p34.internal.lan>
References: <20090713134621.124aa18e.skraw@ithnet.com> <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com> <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com> <20090715084754.36ff73bf.skraw@ithnet.com>
 <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Stephan von Krawczynski <skraw@ithnet.com>, Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>



On Wed, 15 Jul 2009, David Rientjes wrote:

> On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:
>
>> Jul 15 03:01:29 backup kernel: 1444268 total pagecache pages
>> Jul 15 03:01:29 backup kernel: 34 pages in swap cache
>> Jul 15 03:01:29 backup kernel: Swap cache stats: add 118, delete 84, find 0/2
>> Jul 15 03:01:29 backup kernel: Free swap  = 2104080kB
>> Jul 15 03:01:29 backup kernel: Total swap = 2104488kB
>>
>
> I added Justin Piszcz to the cc since he was having the same problem as
> described in http://bugzilla.kernel.org/show_bug.cgi?id=13648.
>
> He was unable to get slabtop -o output when this was happening, though, so
> maybe you could grab a snapshot of that when you get these failures?  It
> will help us figure out what cache the slab leak is in (assuming there is
> one, >1G of slab on this machine is egregious).
>
> Justin, were you using e1000e in your bug report?
Yes:

[    9.302541] e1000e 0000:00:19.0: irq 32 for MSI/MSI-X

I will note with 2.6.30.1 (thus far) it has not re-appeared (yet).

>
> If you have some additional time, it would also be helpful to get a
> bisection of when the problem started occurring (it appears to be sometime
> between 2.6.29 and 2.6.30).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
