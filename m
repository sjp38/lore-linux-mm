Date: Fri, 28 Jul 2000 16:34:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Test5 performance comparison
In-Reply-To: <3981D643.5C2EC40A@sgi.com>
Message-ID: <Pine.LNX.4.21.0007281633170.30922-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jul 2000, Rajagopal Ananthanarayanan wrote:

> In short, test5 looks good, the best ever
> in my experience. In detail:

>               -------Sequential Output-------- ---Sequential Input-- --Random--
>               -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
>  Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU            
> 
> TEST5     256  3618 99.2  11135 16.0  5981 10.8  3005 88.8 18268 17.8 185.4  2.9
> TEST4     256  3630 99.5   9915 14.7  6013 11.3  2894 86.0 18502 19.1 181.4  3.1

This difference is due to the fact that kswapd in -test5 is
woken up on time (when all zones have zone->zone_wake_kswapd
set), whereas the other kernels didn't contain that bugfix.

cheers,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
