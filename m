Date: Mon, 22 Jul 2002 17:05:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
In-Reply-To: <Pine.LNX.4.44L.0207221657460.3086-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2002, Rik van Riel wrote:

> I've gotten two reports of this bug now, but have no idea
> what particular combination of hardware / compiler / config
> triggers the bug. The rmap code seems to have survived akpm's
> stress tests so it's probably not a simple bug to track down ;/

Now that I think about it, could you try enabling RMAP_DEBUG
in mm/rmap.c and try triggering this bug again ?

It's quite possible the debugging code in page_remove_rmap()
will show us a hint...

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
