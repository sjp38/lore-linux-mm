Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 806986B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 13:35:57 -0400 (EDT)
Date: Thu, 9 Jul 2009 10:54:02 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
In-Reply-To: <20090709074745.GT2714@wotan.suse.de>
Message-ID: <alpine.LFD.2.01.0907091053100.3352@localhost.localdomain>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain>
 <20090708062125.GJ2714@wotan.suse.de> <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain> <20090709074745.GT2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



On Thu, 9 Jul 2009, Nick Piggin wrote:
>
> Having a ZERO_PAGE I'm not against, so I don't know why you claim
> I am. Al I'm saying is that now we don't have one, we should have
> some good reasons to introduce it again. Unreasonable?

Umm. I had good reasons to introduce it in the _first_ place.

And now you have reports of people who depend on the behaviour, and point 
to the new behaviour as a *regression*.

What the _hell_ more do you want?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
