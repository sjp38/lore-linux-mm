Date: Tue, 16 May 2000 14:23:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: More observations...
In-Reply-To: <20000516170707.B30047@redhat.com>
Message-ID: <Pine.LNX.4.21.0005161422380.30661-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mike Simons <msimons@moria.simons-clan.com>, Linus Torvalds <torvalds@transmeta.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 May 2000, Stephen C. Tweedie wrote:

> For writable shared file mappings, the flush only goes to the
> buffer cache, not to disk, so we still rely on bdflush
> writeback, but currently filemap_swapout triggers the bdflush
> thread automatically anyway.  Subsequent shrink_mmap reclaims
> will just find a locked page and block, which is the desired
> behaviour.

I can agree on this. Shrink_mmap() should wait if it finds
(a number of) locked buffers.  [It doesn't seem to do that
right now]

Linus??

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
