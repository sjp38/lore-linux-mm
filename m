Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 1D9BE474B9
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 15:15:43 -0200 (BRST)
Date: Tue, 22 Oct 2002 15:15:29 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
In-Reply-To: <3DB5865B.4462537F@digeo.com>
Message-ID: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> >
> > ...
> > In short, we really really want shared page tables.
>
> Or large pages.  I confess to being a little perplexed as to
> why we're pursuing both.

I guess that's due to two things.

1) shared pagetables can speed up fork()+exec() somewhat

2) if we have two options that fix the Oracle problem,
   there's a better chance of getting at least one of
   the two merged ;)

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
