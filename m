Message-ID: <20000706155123.A11504@saw.sw.com.sg>
Date: Thu, 6 Jul 2000 15:51:23 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: page_table_lock problem [was: Re: 2.4 / 2.5 VM plans]
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva> <20000629144408.R3473@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000629144408.R3473@redhat.com>; from "Stephen C. Tweedie" on Thu, Jun 29, 2000 at 02:44:08PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 29, 2000 at 02:44:08PM +0100, Stephen C. Tweedie wrote:
> * RSS accounting needs to be audited.  Right now, the per-mm rss isn't
>   an atomic type, and it doesn't seem to be consistently protected by
>   the page table locks.

Stephen,

I've looked at RSS updates in 2.4.0 kernels.
You're right, they are not protected enough from
concurrent updates from mm paths (mmap, page fault handler) and swapout
path.  Moreover, I found that page_table_lock which is supposed to serialize
page table updates from mm and swapout paths isn't taken in the later at all!
Is it a bug or am I missing something?

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
