Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 385156B002B
	for <linux-mm@kvack.org>; Sun, 23 Sep 2012 03:34:41 -0400 (EDT)
Message-ID: <1348385675.2549.19.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 23 Sep 2012 08:34:35 +0100
In-Reply-To: <20120922010733.GX11266@suse.de>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <20120921161252.GV11266@suse.de>
	 <20120921180222.GA7220@phenom.dumpdata.com>
	 <505CB9BC.8040905@linux.vnet.ibm.com>
	 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
	 <20120922010733.GX11266@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Sat, 2012-09-22 at 02:07 +0100, Mel Gorman wrote:
> > The two proposals:
> > A) Recreate all the work done for zcache2 as a proper sequence of
> >    independent patches and apply them to zcache1. (Seth/Konrad)
> > B) Add zsmalloc back in to zcache2 as an alternative allocator
> >    for frontswap pages. (Dan)
> 
> Throwing it out there but ....
> 
> C) Merge both, but freeze zcache1 except for critical fixes. Only
> allow
>    future work on zcache2. Document limitations of zcache1 and
>    workarounds until zcache2 is fully production ready.
> 
Actually, there is a fourth option, which is the one we'd have usually
used when staging wasn't around:  Throw the old code out as a successful
prototype which showed the author how to do it better (i.e. flush it
from staging) and start again from the new code which has all the
benefits learned from the old code.

Staging isn't supposed to be some magical set of history that we have to
adhere to no matter what (unlike the rest of the tree). It's supposed to
be an accelerator to get stuff into the kernel and not become a
hindrance to it.

There also seem to be a couple of process issues here that could do with
sorting:  Firstly that rewrites on better reflection, while not common,
are also not unusual so we need a mechanism for coping with them.  This
is actually a serious process problem: everyone becomes so attached to
the code they helped clean up that they're hugely unwilling to
countenance a rewrite which would in their (probably correct) opinion
have the cleanups start from ground zero again. Secondly, we've got a
set of use cases and add ons which grew up around code in staging that
act as a bit of a barrier to ABI/API evolution, even as they help to
demonstrate the problems.

I think the first process issue really crystallises the problem we're
having in staging:  we need to get the design approximately right before
we start on the code cleanups.  What I think this means is that we start
on the list where the people who understand the design issues reside
then, when they're happy with the design, we can begin cleaning it up
afterwards if necessary.  I don't think this is hard and fast: there is,
of course, code so bad that even the experts can't penetrate it to see
the design without having their eyes bleed but we should at least always
try to begin with design.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
