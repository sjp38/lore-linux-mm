Date: Mon, 15 May 2000 16:10:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] VM stable again?
In-Reply-To: <20000515200116.E24812@redhat.com>
Message-ID: <Pine.LNX.4.21.0005151608590.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 May 2000, Stephen C. Tweedie wrote:
> On Mon, May 15, 2000 at 12:12:03PM -0300, Rik van Riel wrote:
> > 
> > the patch below makes sure processes won't "eat" the pages
> > another process is freeing and seems to avoid the nasty
> > out of memory situations that people have seen.
> 
> One other thought here --- there is another way to achieve this.
> Make try_to_free_pages() return a struct page *.  That will not
> only achieve some measure of SMP locality, it also guarantees
> that the page freed will be reacquired by the task which did the
> work to free it.

I've thought about this but it doesn't seem worth the extra
complexity to me. Just making sure that while our task is
freeing pages nobody else will grab those pages without having
also freed some pages seems to be enough to me.

Furthermore, the "SMP locality" you talk about will probably
be completely overshadowed by the non-locality of the VM
freeing code anyway...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
