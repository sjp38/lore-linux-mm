Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 659C76B0062
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 11:46:16 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so1151969waf.22
        for <linux-mm@kvack.org>; Tue, 03 Feb 2009 08:44:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090203042405.GB16179@barrios-desktop>
References: <20090203042405.GB16179@barrios-desktop>
Date: Wed, 4 Feb 2009 01:44:52 +0900
Message-ID: <2f11576a0902030844l64c25496sa5f2892bbb04e47c@mail.gmail.com>
Subject: Re: [PATCH v2] fix mlocked page counter mistmatch
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi MinChan,

I'm confusing now.
Can you teach me?

> When I tested following program, I found that mlocked counter
> is strange.
> It couldn't free some mlocked pages of test program.
> It is caused that try_to_unmap_file don't check real
> page mapping in vmas.

What meanining is "real" page mapping?


> That's because goal of address_space for file is to find all processes
> into which the file's specific interval is mapped.
> What I mean is that it's not related page but file's interval.

hmmm. No.
I ran your reproduce program.

two vma pointing the same page cause this leaking.

iow, any library have .text and .data segment. then the tail of .text
and the head of .data vma point the same page.
its page was leaked.


> Even if the page isn't really mapping at the vma, it returns
> SWAP_MLOCK since the vma have VM_LOCKED, then calls
> try_to_mlock_page. After all, mlocked counter is increased again.
>
> COWed anon page in a file-backed vma could be a such case.
> This patch resolves it.

What meaning is "anon page in a file-backed"?
As far as I know, if cow happend on private mapping page, new page is
treated truth anon.


So, I don't reach to your conclusion yet. please teach me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
