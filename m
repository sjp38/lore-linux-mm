Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA21243
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 16:49:46 -0800 (PST)
Date: Thu, 27 Feb 2003 16:46:22 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm1
Message-Id: <20030227164622.032d2ab8.akpm@digeo.com>
In-Reply-To: <200302271917.10139.tomlins@cam.org>
References: <20030227025900.1205425a.akpm@digeo.com>
	<200302271917.10139.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> On February 27, 2003 05:59 am, Andrew Morton wrote:
> > . Tons of changes to the anticipatory scheduler.  It may not be working
> >   very well at present.  Please use "elevator=deadline" if it causes
> >   problems.
> 
> The anticipatory scheduler hangs here at the same place it did in 62-mm2,
> cfq continues to work fine.  A sysrq+T of the hang follows:

I must say, Ed: you have an eerie ability to break stuff.

Please send me your .config.

>                          free                        sibling
>   task             PC    stack   pid father child younger older
> swapper       D DFF8FB20 11876     1      0     2               (L-TLB)

Interesting amount of free stack you have there.  You broke show_task() too!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
