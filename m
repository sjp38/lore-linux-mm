Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 394176B0134
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:13:22 -0400 (EDT)
Date: Wed, 22 Jul 2009 17:12:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
Message-Id: <20090722171245.d5b3a108.akpm@linux-foundation.org>
In-Reply-To: <20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
	<20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, hugh.dickins@tiscali.co.uk, avi@redhat.com, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 2009 08:51:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 16 Jul 2009 18:01:34 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > Rebased onto  mm-of-the-moment snapshot 2009-07-15-20-57.
> > And modifeied to make vm_normal_page() eat FOLL_NOZERO, directly.
> > 
> > Any comments ?
> > 
> 
> A week passed since I posted this.

I'm catching up at a rate of 2.5 days per day.  Am presently up to July
16.  I never know whether to work through it forwards or in reverse.

Geeze you guys send a lot of stuff.  Stop writing new code and go fix
some bugs!

> It's no problem to keep updating this
> and post again. But if anyone have concerns, please notify me.
> I'll reduce CC: list in the next post.

ok...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
