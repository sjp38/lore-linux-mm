Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA28819
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 11:49:10 -0700 (PDT)
Message-ID: <3DB59DA7.453F89E2@digeo.com>
Date: Tue, 22 Oct 2002 11:49:11 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
References: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conectiva> <145460000.1035311809@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> --On Tuesday, October 22, 2002 15:15:29 -0200 Rik van Riel
> <riel@conectiva.com.br> wrote:
> 
> >> Or large pages.  I confess to being a little perplexed as to
> >> why we're pursuing both.
> >
> > I guess that's due to two things.
> >
> > 1) shared pagetables can speed up fork()+exec() somewhat
> >
> > 2) if we have two options that fix the Oracle problem,
> >    there's a better chance of getting at least one of
> >    the two merged ;)
> 
> And
>   3) The current large page implementation is only for applications
>      that want anonymous *non-pageable* shared memory.  Shared page
>      tables reduce resource usage for any shared area that's mapped
>      at a common address and is large enough to span entire pte pages.
>      Since all pte pages are shared on a COW basis at fork time, children
>      will continue to share all large read-only areas with their
>      parent, eg large executables.
> 

How important is that in practice?

Seems that large pages are the preferred solution to the "Oracle
and DB2 use gobs of pagetable" problem because large pages also
reduce tlb reload traffic.

So once that's out of the picture, what real-world, observed,
customers-are-hurting problem is solved by pagetable sharing?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
