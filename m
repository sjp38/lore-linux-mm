Date: Mon, 15 May 2000 20:01:16 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] VM stable again?
Message-ID: <20000515200116.E24812@redhat.com>
References: <Pine.LNX.4.21.0005151157240.20410-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005151157240.20410-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, May 15, 2000 at 12:12:03PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, May 15, 2000 at 12:12:03PM -0300, Rik van Riel wrote:
> 
> the patch below makes sure processes won't "eat" the pages
> another process is freeing and seems to avoid the nasty
> out of memory situations that people have seen.

One other thought here --- there is another way to achieve this.
Make try_to_free_pages() return a struct page *.  That will not
only achieve some measure of SMP locality, it also guarantees that
the page freed will be reacquired by the task which did the work to
free it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
