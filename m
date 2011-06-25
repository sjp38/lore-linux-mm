Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4628B90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 22:43:06 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2606515pvc.14
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 19:43:03 -0700 (PDT)
Message-ID: <4E054B0D.9090802@vflare.org>
Date: Fri, 24 Jun 2011 19:42:21 -0700
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com>	 <4E042A84.5010204@vflare.org> <1308930764.11430.462.camel@nimitz>
In-Reply-To: <1308930764.11430.462.camel@nimitz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>

On 06/24/2011 08:52 AM, Dave Hansen wrote:
> On Thu, 2011-06-23 at 23:11 -0700, Nitin Gupta wrote:
>> Much of this vpage functionality seems to be already present in mainline
>> as "flexible arrays"[1]
>
> That's a good observation.  I don't know who wrote that junk, but I bet
> they never thought of using it for this purpose. :)
>
> FWIW, for flex_arrays, the biggest limitation is that the objects
> currently can not cross page boundaries.  The current API also doesn't
> have any concept of a release function.  We'd need those to do the
> unmapping after a get().  It certainly wouldn't be impossible to fix,
> but it would probably make it quite a bit more complicated.
>
> The other limitation is that each array can only hold a small number of
> megabytes worth of data in each array.  We only have a single-level
> table lookup, and that first-level table is limited to PAGE_SIZE (minus
> a wee bit of metadata).
>

These limitations really makes them unsuitable for use in the new 
allocator and I guess "fixing" them is also not a good idea -- if its 
fundamentally designed to work on small number of objects, it should 
probably be left as-is.  Not sure who really uses flex arrays?

So, if and when vpage stuff is introduced, existence of flex_arrays 
should not become a barrier.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
