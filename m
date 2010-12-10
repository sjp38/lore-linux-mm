Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B12806B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 01:22:18 -0500 (EST)
Received: from mail-iw0-f178.google.com (mail-iw0-f178.google.com [209.85.214.178])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oBA6LhOs029981
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 22:21:44 -0800
Received: by iwn1 with SMTP id 1so5046479iwn.37
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 22:21:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
	<20101208152740.ac449c3d.akpm@linux-foundation.org>
	<AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
Date: Thu, 9 Dec 2010 22:11:30 -0800
Message-ID: <AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday, December 8, 2010, Michel Lespinasse <walken@google.com> wrote:
>
> Yes, patch 1/6 changes the long hold time to be in read mode instead
> of write mode, which is only a band-aid. But, this prepares for patch
> 5/6, which releases mmap_sem whenever there is contention on it or
> when blocking on disk reads.

I have to say that I'm not a huge fan of that horribly kludgy
contention check case.

The "move page-in to read-locked sequence" and the changes to
get_user_pages look fine, but the contention thing is just disgusting.
I'd really like to see some other approach if at all possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
