Date: Mon, 9 Oct 2000 20:11:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Write-back/VM question
In-Reply-To: <39E25034.6B1203CE@sgi.com>
Message-ID: <Pine.LNX.4.21.0010092010480.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Rajagopal Ananthanarayanan wrote:

> One of the behaviors of the new VM seems to be that it starts
> I/O on a written page fairly early. This "aggressive" write is
> great for streaming I/O, but seems to have a penalty when the
> application has write-locality. Dbench is a one case, which is
> write intensive and a lot of the writes are to a previously
> written page.
> 
> I'm not exactly certain why starting write-out early would cause
> problems, but I've a couple of quick questions:
> 
> 1. Is the page locked during write-out?

The buffers on the page are. I'm not sure about the page
itself though ...

> 2. Is there a tuneable that I can use to
>    control write-back behaviour?

/proc/sys/vm/bdflush, first value

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
