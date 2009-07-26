Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B45816B00A2
	for <linux-mm@kvack.org>; Sun, 26 Jul 2009 12:01:19 -0400 (EDT)
Date: Sun, 26 Jul 2009 17:00:54 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
In-Reply-To: <20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0907261639570.32238@sister.anvils>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
 <20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
 <20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
 <20090722171245.d5b3a108.akpm@linux-foundation.org>
 <20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, avi@redhat.com, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 2009, KAMEZAWA Hiroyuki wrote:
> On Wed, 22 Jul 2009 17:12:45 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 23 Jul 2009 08:51:37 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Thu, 16 Jul 2009 18:01:34 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > 
> > > > Rebased onto  mm-of-the-moment snapshot 2009-07-15-20-57.
> > > > And modifeied to make vm_normal_page() eat FOLL_NOZERO, directly.
> > > > 
> > > > Any comments ?

Sorry, I've been waiting to have something positive to suggest,
but today still busy with my own issues (handling OOM in KSM).

I do dislike that additional argument to vm_normal_page, and
feel that's a problem to be solved in follow_page, rather
than spread to every other vm_normal_page user.

Does follow_page even need to be using vm_normal_page?
Hmm, VM_MIXEDMAP, __get_user_pages doesn't exclude that.

I also feel a strong (but not yet fulfilled) urge to check
all the use_zero_page ignore_zero stuff: which is far from
self-evident.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
