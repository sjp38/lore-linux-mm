Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81BCC8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:35:37 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2NEZ4Lo006947
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 07:35:04 -0700
Received: by iyf13 with SMTP id 13so11848505iyf.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 07:35:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110323171051.1ADA.A69D9226@jp.fujitsu.com>
References: <20110322200945.B06D.A69D9226@jp.fujitsu.com> <20110323164949.5be6aa48.kamezawa.hiroyu@jp.fujitsu.com>
 <20110323171051.1ADA.A69D9226@jp.fujitsu.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Mar 2011 07:34:43 -0700
Message-ID: <AANLkTimLbaMTHKiuWu5edS4Offf4KZv2TJ+g8BUgzLYt@mail.gmail.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>

On Wed, Mar 23, 2011 at 1:09 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> When __lock_page_or_retry() return 0, It call up_read(mmap_sem) in this
> function.

Indeed.

> I agree this is strange (or ugly). but I don't want change this spec in
> this time.

I agree that it is strange, and I don't like functions that touch
locks that they didn't take themselves, but since the original point
of the whole thing was to wait for the page without holding the
mmap_sem lock, that function has to do the up_read() early.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
