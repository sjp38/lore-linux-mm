Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 165316B002D
	for <linux-mm@kvack.org>; Sat, 29 Oct 2011 09:43:15 -0400 (EDT)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Date: Sat, 29 Oct 2011 09:43:08 -0400
Message-ID: <1777884.rjTZT9Wj01@grover>
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Thursday 27 October 2011 11:52:22 Dan Magenheimer wrote:
> Hi Linus --

> SO... Please pull:
> 
> git://oss.oracle.com/git/djm/tmem.git #tmem
> 

My wife has an old PC thats short on memory.  Its got Ubuntu
running on it.  It also has cleancache and zram enabled.  The
box works better when using these.  Frontcache would improve 
things further.  It will balance the tmem vs physical memory
dynamicily making it a better solution than zram.

I'd love to see this in the kernel.

Thanks
Ed Tomlinson

PS.  At work we use AIX with memory compression.  With the
workloads we run compression lets the OS act like it has 30%
more memory.  It works.  It would be nice to have a similar
facility in Linux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
