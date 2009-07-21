Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 602616B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 09:38:15 -0400 (EDT)
Date: Tue, 21 Jul 2009 15:38:12 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090721153812.a0e0c96a.skraw@ithnet.com>
In-Reply-To: <alpine.DEB.2.00.0907151323170.22582@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
	<4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
	<alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
	<20090715084754.36ff73bf.skraw@ithnet.com>
	<alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
	<20090715113740.334309dd.skraw@ithnet.com>
	<alpine.DEB.2.00.0907151323170.22582@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Justin Piszcz <jpiszcz@lucidpixels.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 13:24:08 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:
> 
> > > If you have some additional time, it would also be helpful to get a 
> > > bisection of when the problem started occurring (it appears to be sometime 
> > > between 2.6.29 and 2.6.30).
> > 
> > Do you know what version should definitely be not affected? I can check one
> > kernel version per day, can you name a list which versions to check out? 
> > 
> 
> To my knowledge, this issue was never reported on 2.6.29, so that should 
> be a sane starting point.

Since we cannot see the problem in 2.6.27.26, we now try 2.6.30.2.

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
