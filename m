Date: Fri, 1 Sep 2000 15:18:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Rik's drop behind stuff
In-Reply-To: <39AFEE6C.81623F5C@ucla.edu>
Message-ID: <Pine.LNX.4.21.0009011517460.1110-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Sep 2000, Benjamin Redelings I wrote:

> presented a general mechanism for doing drop_behind, that actually
> generalized, instead of being a special case hack?

Actually it's still a little bit special case, since readahead
(and drop behind) is only done on a filedescriptor level and
not on the VMA level.

OTOH, I've heard rumours that Ben LaHaise is moving readahead
to the VMA level. When that is done my drop-behind code will
automagically work for mmap() and swap too...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
