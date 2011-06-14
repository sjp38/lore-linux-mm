Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E48946B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 13:29:55 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5EHTpw6003592
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:29:52 -0700
Received: by wyf19 with SMTP id 19so5408424wyf.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:29:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 14 Jun 2011 10:29:30 -0700
Message-ID: <BANLkTintgwYuUcMjY91gGk8G07wmWyQ1sw@mail.gmail.com>
Subject: Re: [PATCH 0/12] tmpfs: convert from old swap vector to radix tree
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 14, 2011 at 3:40 AM, Hugh Dickins <hughd@google.com> wrote:
>
> thus saving memory, and simplifying its code and locking.
>
> =A013 files changed, 669 insertions(+), 1144 deletions(-)

Hey, I can Ack this just based on the fact that for once "simplifying
its code" clearly also removes code. Yay! Too many times the code
becomes "simpler" but bigger.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
