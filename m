Date: Mon, 2 Oct 2000 14:17:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] fix for VM  test9-pre7
In-Reply-To: <qwwu2avxkbx.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0010021411400.22539-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: linux-kernel@vger.redhat.com, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 2 Oct 2000, Christoph Rohland wrote:

> the shm swapping still kills the machine(8GB mem) the machine
> with somthing like '__alloc_pages failed order 0'.
> 
> When I do the same stresstest with mmaped file in ext2 the
> machine runs fine but the processes do not do anything and
> vmstat/ps lock up on these processes.

This may be a highmem bounce-buffer creation deadlock. Do
your tests work if you use only 800 MB of RAM ?

Shared memory swapping on my 64 MB test machine seems to
work fine (albeit a bit slow).

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
