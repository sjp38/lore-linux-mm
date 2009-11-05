Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7767B6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:02:14 -0500 (EST)
Date: Thu, 5 Nov 2009 20:02:03 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH] oom_kill: avoid depends on total_vm and use real
	RSS/swap value for oom_score (Re: Memory overcommit
Message-ID: <20091105190203.GA1392@ucw.cz>
References: <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com> <20091027153429.b36866c4.minchan.kim@barrios-desktop> <20091027153626.c5a4b5be.kamezawa.hiroyu@jp.fujitsu.com> <28c262360910262355p3cac5c1bla4de9d42ea67fb4e@mail.gmail.com> <20091027164526.da6a23cb.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271821130.11372@sister.anvils> <20091027184743.GD5753@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027184743.GD5753@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Hi!

> Agreed it's not obvious. Intuitively I think only including RSS and no
> swap is best, but clearly I can't be entirely against including swap
> too as there may be scenarios where including swap provides for a
> better choice.
> 
> My argument for not including swap is that we kill tasks to free RAM
> (we don't really care to free swap, system needs RAM at oom time).

System should be out of _virtual_ memory at that point, so yes,
freeing swap should help, too.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
