Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DAFFB6B005D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 04:59:42 -0400 (EDT)
Date: Wed, 15 Jul 2009 11:37:40 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090715113740.334309dd.skraw@ithnet.com>
In-Reply-To: <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
	<4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
	<alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
	<20090715084754.36ff73bf.skraw@ithnet.com>
	<alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Justin Piszcz <jpiszcz@lucidpixels.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 01:18:02 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:
> [...]
> I added Justin Piszcz to the cc since he was having the same problem as 
> described in http://bugzilla.kernel.org/show_bug.cgi?id=13648.
> 
> He was unable to get slabtop -o output when this was happening, though, so 
> maybe you could grab a snapshot of that when you get these failures?  It 
> will help us figure out what cache the slab leak is in (assuming there is 
> one, >1G of slab on this machine is egregious).

I am pretty sure I can handle that. From the timestamps it looks like it
always happens when large amounts of data come in from rsyncs. These are
cronjobs, so I got the time.
Question: I just checked "slabtop -o" and found out it outputs exactly
nothing, whereas slabtop (without option -o) shows up just like (process) top
with lots of lines. Can you clarify why there is no console output at all with
option -o ? 

> Justin, were you using e1000e in your bug report?
> 
> If you have some additional time, it would also be helpful to get a 
> bisection of when the problem started occurring (it appears to be sometime 
> between 2.6.29 and 2.6.30).

Do you know what version should definitely be not affected? I can check one
kernel version per day, can you name a list which versions to check out? 

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
