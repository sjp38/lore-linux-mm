Date: Sun, 3 Sep 2000 16:40:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Oopses as discussed on irc
In-Reply-To: <m3zolpb8he.fsf@kalahari.s2.org>
Message-ID: <Pine.LNX.4.21.0009031639470.1112-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jarno Paananen <jpaana@s2.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3 Sep 2000, Jarno Paananen wrote:

> ksymoops 2.3.4 on i686 2.4.0-test8.  Options used
> 
> Warning: You did not tell me where to find symbol information.  I will

> Error (regular_file): read_system_map stat
> /boot/System.map-2.4.0-test8 failed

> 1 warning and 1 error issued.  Results may not be reliable.

And they're not.

These traces do /not/ correspond to the BUG() numbers
given. Please use the correct System.map when generating
the backtraces ;)

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
