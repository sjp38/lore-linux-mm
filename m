Date: Wed, 16 Aug 2000 19:57:06 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.4.0-test7-pre4-vm2 results
In-Reply-To: <Pine.OSF.4.20.0008170130550.7212-200000@sirppi.helsinki.fi>
Message-ID: <Pine.LNX.4.21.0008161954300.11439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0008161954302.11439@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aki M Laukkanen <amlaukka@cc.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Aug 2000, Aki M Laukkanen wrote:

> I tested the patch with two workloads on 2x466 Celeron/128MB. Btw. I couldn't
> trigger the SMP race with these tests. What kind of workload is needed?
> 
> * make -j30 bzImage
> 
> * bonnie++ -s 512

Your workload is ok, maybe you just need more patience ;)

I managed to trigger the bug once today, in 30 minutes of
_heavy_ testing. Also, my copy of the code has boobytraps
all over the place, and none of them catch the bug (except
swap.c:232)...

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
