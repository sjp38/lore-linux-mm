Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E79D66B004D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:24:45 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3OELL71005326
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:21:21 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3OEP7wO198514
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:25:07 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3OEP3va032625
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:25:06 -0400
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090424092151.GA14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	 <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
	 <1240421415.10627.93.camel@nimitz> <20090423001311.GA26643@csn.ul.ie>
	 <1240450447.10627.119.camel@nimitz> <1240514784.10627.171.camel@nimitz>
	 <1240515930.10627.175.camel@nimitz>  <20090424092151.GA14283@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 24 Apr 2009 07:25:00 -0700
Message-Id: <1240583100.29485.5.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-04-24 at 10:21 +0100, Mel Gorman wrote:
> > dave@kernel:~/work/mhp-build$ ../linux-2.6.git/scripts/bloat-o-meter
> > i386-numaq-sparse.{1,2}/vmlinux 
> > add/remove: 0/0 grow/shrink: 9/16 up/down: 81/-99 (-18)
> > function                                     old     new   delta
> > st_int_ioctl                                2600    2624     +24
> > tcp_sendmsg                                 2153    2169     +16
> > diskstats_show                               739     753     +14
> > iov_shorten                                   49      58      +9
> > unmap_vmas                                  1653    1661      +8
> > sg_build_indirect                            449     455      +6
> > ahc_linux_biosparam                          251     253      +2
> > nlmclnt_call                                 557     558      +1
> > do_mount                                    1533    1534      +1
> 
> It doesn't make sense at all that text increased in size. Did you make clean
> between each .config change and patch application? Are you using distcc
> or anything else that might cause confusion? I found I had to eliminate
> distscc and clean after each patch application because sometimes
> net/ipv4/udp.c would sometimes generate different assembly when
> accessing struct zone. Not really sure what was going on there.

There's a ccache in there but no distcc.

I'll redo with clean builds.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
