Date: Sun, 20 Aug 2000 19:15:15 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Performance: test6, 7-5, 7-5 Multiqueue, history
In-Reply-To: <39A02880.54E3C08@sgi.com>
Message-ID: <Pine.LNX.4.21.0008201911130.5411-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Aug 2000, Rajagopal Ananthanarayanan wrote:

>  o test5 continues to yield the best performance.
>  o test5 -> test6 (and in test7-5) block I/O performance degraded about 10%.

Interesting, I wonder why this is (and I'll look into it
tomorrow to find out what happened and to fix it).

>  o MQ patch yields bad performance in most cases; perhaps changes
>    between test7-pre4 and test7-pre5 don't sit well with MQ changes,
>    since I used the t7p4 MQ patch.

The problem which causes this is that bdflush in the
multiqueue vm writes out pages in the 'wrong' order
sometimes. I'll fix this ASAP.

(I think I'll make a a heisenbug compensator for the
SMP bug and get on with life)

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
