Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 397136B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 16:24:12 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6FKODaQ020162
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:24:15 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by spaceape11.eur.corp.google.com with ESMTP id n6FKOACW026828
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:24:11 -0700
Received: by pxi2 with SMTP id 2so1749401pxi.8
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:24:10 -0700 (PDT)
Date: Wed, 15 Jul 2009 13:24:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: What to do with this message (2.6.30.1) ?
In-Reply-To: <20090715113740.334309dd.skraw@ithnet.com>
Message-ID: <alpine.DEB.2.00.0907151323170.22582@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com> <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com> <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com> <20090715084754.36ff73bf.skraw@ithnet.com> <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
 <20090715113740.334309dd.skraw@ithnet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephan von Krawczynski <skraw@ithnet.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Justin Piszcz <jpiszcz@lucidpixels.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:

> > If you have some additional time, it would also be helpful to get a 
> > bisection of when the problem started occurring (it appears to be sometime 
> > between 2.6.29 and 2.6.30).
> 
> Do you know what version should definitely be not affected? I can check one
> kernel version per day, can you name a list which versions to check out? 
> 

To my knowledge, this issue was never reported on 2.6.29, so that should 
be a sane starting point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
