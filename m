Message-ID: <20001002120559.13349.qmail@theseus.mathematik.uni-ulm.de>
From: ehrhardt@mathematik.uni-ulm.de
Date: Mon, 2 Oct 2000 14:05:59 +0200
Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 12:42:47AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Oct 02, 2000 at 12:42:47AM -0300, Rik van Riel wrote:
> --- linux-2.4.0-test9-pre7/fs/buffer.c.orig	Sat Sep 30 18:09:18 2000
> +++ linux-2.4.0-test9-pre7/fs/buffer.c	Mon Oct  2 00:19:41 2000
> @@ -706,7 +706,9 @@
>  static void refill_freelist(int size)
>  {
>  	if (!grow_buffers(size)) {
> -		try_to_free_pages(GFP_BUFFER);
> +		wakeup_bdflush(1);
> +		current->policy |= SCHED_YIELD;
> +		schedule();
>  	}
>  }

This part looks strange! wakeup_bdflush will sleep if the parameter
is not zero, i.e. we'll schedule twice. I doubt that this the intended
behaviour?

    regards    Christian

-- 
THAT'S ALL FOLKS!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
