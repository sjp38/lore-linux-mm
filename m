Date: Sat, 24 May 2003 17:51:06 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: VM problem in 2.5.69-mm5
Message-Id: <20030524175106.385f8e45.akpm@digeo.com>
In-Reply-To: <1053822686.32330.35.camel@tux.rsn.bth.se>
References: <1053822686.32330.35.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Josefsson <gandalf@wlug.westbo.se> wrote:
>
> 2.5.69-mm5 has some serious problems on my machine (pIII 700 704MB ram,
>  512MB swap)

So you do.

Don't know.  You could try `elevator=deadline' to rule that out.

What filesystems are in use?

file_lock_cache seems rather large (irrelevantly)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
