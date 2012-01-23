Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EF1876B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:40:27 -0500 (EST)
Date: Mon, 23 Jan 2012 11:40:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation
 library
Message-Id: <20120123114025.afd48d17.akpm@linux-foundation.org>
In-Reply-To: <4F1DADA0.4030300@vflare.org>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com>
	<20120120141232.a7572919.akpm@linux-foundation.org>
	<4F1DADA0.4030300@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, 23 Jan 2012 13:57:36 -0500
Nitin Gupta <ngupta@vflare.org> wrote:

> > afacit this code should be added to core mm/.  Addition of code like
> > this to core mm/ will be fiercely resisted on principle!  Hence the
> > (currently missing) justifications for adding it had best be good ones.
> > 
> 
> 
> I don't think this code should ever get into mm/ since its just a driver
> specific allocator.

Like mm/mempool.c and mm/dmapool.c ;)

> However its used by more than one driver (zcache and
> zram) so it may be moved to lib/ or drivers/zsmalloc atmost?

I'd need to take another look at the code, but if the allocator is a
good and useful thing then we want other kernel code to use it where
possible and appropriate. Putting it in mm/ or lib/ says "hey, use this".

The code is extensively poking around in MM internals, especially the
pageframe fields.  So I'd say it's a part of MM (in mm/) rather than a
clean client of MM, which would place it in lib/.


btw, kmap_atomic() already returns void*, so casting its return value
is unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
