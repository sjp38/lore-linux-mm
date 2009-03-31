Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 765C36B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 18:08:35 -0400 (EDT)
Date: Tue, 31 Mar 2009 15:00:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2][PATCH]page_fault retry with NOPAGE_RETRY
Message-Id: <20090331150046.16539218.akpm@linux-foundation.org>
In-Reply-To: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com>
References: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 5 Dec 2008 11:40:19 -0800
Ying Han <yinghan@google.com> wrote:

> changelog[v2]:
> - reduce the runtime overhead by extending the 'write' flag of
>   handle_mm_fault() to indicate the retry hint.
> - add another two branches in filemap_fault with retry logic.
> - replace find_lock_page with find_lock_page_retry to make the code
>   cleaner.
> 
> todo:
> - there is potential a starvation hole with the retry. By the time the
>   retry returns, the pages might be released. we can make change by holding
>   page reference as well as remembering what the page "was"(in case the
>   file was truncated). any suggestion here are welcomed.
> 
> I also made patches for all other arch. I am posting x86_64 here first and
> i will post others by the time everyone feels comfortable of this patch.

I'm about to send this into Linus.  What happened to the patches for
other architectures?

Please send them over when convenient and I'll work on getting them
trickled out to arch maintainers, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
