Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E5096B006A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 05:08:04 -0400 (EDT)
Date: Wed, 15 Jul 2009 11:46:05 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090715114605.42a354c0.skraw@ithnet.com>
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


> [slabtop -o]

Ok, so I just found out that slabtop -o outputs a lot of ANSI code by
redirecting it, that output is merely unreadable. Can some kind soul please
tell the author that formatting ANSI output in -o option makes no sense at
all. top btw does not do this (top -b -n 1).
I will produce your logs, but you will have a hard time reading that trash ...

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
