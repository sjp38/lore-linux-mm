Received: from midway.site ([71.117.236.25]) by xenotime.net for <linux-mm@kvack.org>; Wed, 11 Jul 2007 08:42:02 -0700
Date: Wed, 11 Jul 2007 08:45:49 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
Message-Id: <20070711084549.93bb433e.rdunlap@xenotime.net>
In-Reply-To: <20070711122324.GA21714@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<20070711122324.GA21714@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007 14:23:24 +0200 Christoph Hellwig wrote:

...

> > lguest-the-guest-code.patch
> > lguest-the-host-code.patch
> > lguest-the-host-code-lguest-vs-clockevents-fix-resume-logic.patch
> > lguest-the-asm-offsets.patch
> > lguest-the-makefile-and-kconfig.patch
> > lguest-the-console-driver.patch
> > lguest-the-net-driver.patch
> > lguest-the-block-driver.patch
> > lguest-the-documentation-example-launcher.patch
> 
> Just started to reading this (again) so no useful comment here, but it
> would be nice if the code could follow CodingStyle and place the || and
> && at the end of the line in multiline conditionals instead of at the
> beginning of the new one.

I prefer them at the ends of lines also, but that's not in CodingStyle,
it's just how we do it most of the time (so "coding style", without
caps).

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
