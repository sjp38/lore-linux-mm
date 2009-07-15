Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AA6206B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 16:22:53 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n6FKMuSg019367
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:22:57 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz1.hot.corp.google.com with ESMTP id n6FKMsD9013954
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:22:54 -0700
Received: by pzk2 with SMTP id 2so2964620pzk.23
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:22:54 -0700 (PDT)
Date: Wed, 15 Jul 2009 13:22:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: What to do with this message (2.6.30.1) ?
In-Reply-To: <20090715114605.42a354c0.skraw@ithnet.com>
Message-ID: <alpine.DEB.2.00.0907151321030.22582@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com> <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com> <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com> <20090715084754.36ff73bf.skraw@ithnet.com> <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
 <20090715114605.42a354c0.skraw@ithnet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Stephan von Krawczynski <skraw@ithnet.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, Justin Piszcz <jpiszcz@lucidpixels.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:

> Ok, so I just found out that slabtop -o outputs a lot of ANSI code by
> redirecting it, that output is merely unreadable. Can some kind soul please
> tell the author that formatting ANSI output in -o option makes no sense at
> all. top btw does not do this (top -b -n 1).
> I will produce your logs, but you will have a hard time reading that trash ...
> 

This is fixed in the latest release of procps[*], so maybe you could 
upgrade before generating the output?  If not, simply sending 
/proc/slabinfo would be better.

 [*] https://rhn.redhat.com/errata/RHBA-2009-0950.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
