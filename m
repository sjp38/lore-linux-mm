Date: Sat, 22 May 2004 23:58:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: current -linus tree dies on x86_64
Message-Id: <20040522235831.7bdb509d.akpm@osdl.org>
In-Reply-To: <20040522144857.3af1fc2c.akpm@osdl.org>
References: <20040522144857.3af1fc2c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> As soon as I put in enough memory pressure to start swapping it oopses in
>  release_pages().

I'm doing the bsearch on this.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
