Date: Wed, 25 Oct 2000 16:02:01 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: New mm and highmem reminder
In-Reply-To: <qwwy9zcam3x.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0010251601120.943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 25 Oct 2000, Christoph Rohland wrote:

> Just wanted to remind you that swapping shm in highmem is still
> broken in the latest patches.
> 
> If I return a RETRY in shm_swap_core instead of FAILED for
> failures of prepare_highmem_swapout it survives a little bit
> longer spewing lots of 'order 0 allocation failed' and then
> locks up after doing some swapping. Without this change it
> hardly swaps at all before lockup.

Could you test if /normal/ swapping works on highmem
machines?

If it does, it is ipc/shm.c which does the wrong thing
when no bounce buffer could be created...

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
