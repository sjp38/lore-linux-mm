From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14543.57493.860685.448837@dukat.scot.redhat.com>
Date: Wed, 15 Mar 2000 19:12:21 +0000 (GMT)
Subject: Re: [PATCH] madvise() against 2.3.52-3
In-Reply-To: <Pine.BSO.4.10.10003141806190.19943-100000@funky.monkey.org>
References: <Pine.BSO.4.10.10003141806190.19943-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 14 Mar 2000 18:13:19 -0500 (EST), Chuck Lever <cel@monkey.org>
said:

> +	lock_kernel();	/* is this really necessary? */
> +
> +	flush_cache_range(vma->vm_mm, start, end);
> +	zap_page_range(vma->vm_mm, start, end - start);
> +	flush_tlb_range(vma->vm_mm, start, end);
> +
> +	unlock_kernel();

I'd have thought we'd be safe without it --- the zap_page_range()
already takes the page table lock,  The flush_tlb_range should be safe
on SMP without the kernel lock now, shouldn't it?  We certainly take a
tlb lock on Intel to guard this --- I'm not sure if it's 100% safe on
other architectures.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
