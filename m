Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C05AD90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:53:00 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5OFVCdR021044
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:31:12 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5OFqtnK893080
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:52:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5OFqtqr032247
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:52:55 -0400
Subject: Re: frontswap/zcache: xvmalloc discussion
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4E042A84.5010204@vflare.org>
References: <4E023F61.8080904@linux.vnet.ibm.com>
	 <4E042A84.5010204@vflare.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 24 Jun 2011 08:52:44 -0700
Message-ID: <1308930764.11430.462.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

On Thu, 2011-06-23 at 23:11 -0700, Nitin Gupta wrote:
> Much of this vpage functionality seems to be already present in mainline 
> as "flexible arrays"[1] 

That's a good observation.  I don't know who wrote that junk, but I bet
they never thought of using it for this purpose. :)

FWIW, for flex_arrays, the biggest limitation is that the objects
currently can not cross page boundaries.  The current API also doesn't
have any concept of a release function.  We'd need those to do the
unmapping after a get().  It certainly wouldn't be impossible to fix,
but it would probably make it quite a bit more complicated.

The other limitation is that each array can only hold a small number of
megabytes worth of data in each array.  We only have a single-level
table lookup, and that first-level table is limited to PAGE_SIZE (minus
a wee bit of metadata).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
