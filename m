Date: Mon, 14 Apr 2003 21:31:14 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm3
Message-Id: <20030414213114.37dc7879.akpm@digeo.com>
In-Reply-To: <20030415041759.GA12487@holomorphy.com>
References: <20030414015313.4f6333ad.akpm@digeo.com>
	<20030415020057.GC706@holomorphy.com>
	<20030415041759.GA12487@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
> +	for (; addr < (unsigned long)uaddr + size && !ret; addr += PAGE_SIZE)
> +		ret = __put_user(0, (char *)max(addr, (unsigned long)uaddr));

This hurts my brain.  If anything, it should be formulated as a do-while loop.

But I'm not sure we should really bother, because relatively large amounts of
stuff is broken for PAGE_SIZE != PAGE_CACHE_SIZE anyway.  tmpfs comes to
mind...

If page clustering needs to redo this code (and I assume it does) then that
would be an argument in favour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
