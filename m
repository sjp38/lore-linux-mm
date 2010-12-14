Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33B726B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 18:22:41 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oBENMbLq013196
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 15:22:39 -0800
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by kpbe14.cbf.corp.google.com with ESMTP id oBENMZfn009810
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 15:22:36 -0800
Received: by qwk4 with SMTP id 4so1326586qwk.4
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 15:22:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTim-sV6JO5apPdd9oG23q3THaZ1FazfF1nqUfs6C@mail.gmail.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
	<20101208152740.ac449c3d.akpm@linux-foundation.org>
	<AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
	<AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
	<20101214005140.GA29904@google.com>
	<20101213170526.3b010058.akpm@linux-foundation.org>
	<AANLkTim-sV6JO5apPdd9oG23q3THaZ1FazfF1nqUfs6C@mail.gmail.com>
Date: Tue, 14 Dec 2010 15:22:35 -0800
Message-ID: <AANLkTim-CBKeXYiK=TWHafcEto32mKAqCggTVW5-r9nj@mail.gmail.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 7:43 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Without _any_ at all of the crappy "rwsem_contended()" or the stupid
> constants, we hold it only for reading, _and_ we drop it for any
> actual IO. So the semaphore is held only for actual CPU intensive
> cases. We're talking a reduction from minutes to milliseconds.

It's actually still several seconds for a large enough mlock from page cache.

But yes, I agree it'll do fine for now :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
