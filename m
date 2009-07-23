Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 28D956B0138
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:35:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6N0ZP8i001974
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Jul 2009 09:35:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C1EC345DE56
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 09:35:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 246D445DE50
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 09:35:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 096C61DB803A
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 09:35:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A4BE08005
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 09:35:24 +0900 (JST)
Date: Thu, 23 Jul 2009 09:33:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] ZERO PAGE again v4.
Message-Id: <20090723093334.3166e9d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090722171245.d5b3a108.akpm@linux-foundation.org>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
	<20090723085137.b14fe267.kamezawa.hiroyu@jp.fujitsu.com>
	<20090722171245.d5b3a108.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, hugh.dickins@tiscali.co.uk, avi@redhat.com, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jul 2009 17:12:45 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 23 Jul 2009 08:51:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 16 Jul 2009 18:01:34 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > 
> > > Rebased onto  mm-of-the-moment snapshot 2009-07-15-20-57.
> > > And modifeied to make vm_normal_page() eat FOLL_NOZERO, directly.
> > > 
> > > Any comments ?
> > > 
> > 
> > A week passed since I posted this.
> 
> I'm catching up at a rate of 2.5 days per day.  Am presently up to July
> 16.  I never know whether to work through it forwards or in reverse.
> 
> Geeze you guys send a lot of stuff.  Stop writing new code and go fix
> some bugs!
> 
In these months, I myself don't write any new feature.
I'm now in stablization stage.
(ZERO_PAGE is not new feature in my point of view.)

Remainig big one is Direce-I/O v.s. fork() fix.

> > It's no problem to keep updating this
> > and post again. But if anyone have concerns, please notify me.
> > I'll reduce CC: list in the next post.
> 
> ok...
> 
I'll postpone v5 until the next week.

Thank you for your efforts.

BTW, when I post new version, should I send a reply to old version to say
"this version is obsolete" ? Can it make your work easier ? like following.

Re:[PATCH][Obsolete] new version weill come (Was.....)

I tend to update patches until v5 or more until merged.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
