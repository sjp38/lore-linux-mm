Date: Wed, 4 Sep 2002 10:32:14 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D75E054.B341E067@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041030510.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:

> - If the page is dirty, and mapped into pagetables then write the
>   thing anyway (haven't tested this yet).  This is to get around the
>   problem of big dirty mmaps - everything stalls on request queues.
>   Oh well.

I don't think we need this.  If the request queue is saturated, and
free memory is low, the request queue is guaranteed to be full of
writes, which will result in memory becoming freeable soon.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
