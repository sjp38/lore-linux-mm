Date: Sat, 16 Feb 2002 18:32:11 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] shrink struct page for 2.5
In-Reply-To: <20020216212327.C4777@suse.de>
Message-ID: <Pine.LNX.4.33L.0202161829520.1930-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2002, Dave Jones wrote:
> On Sat, Feb 16, 2002 at 06:15:03PM -0200, Rik van Riel wrote:

>  > I've forward-ported a small part of the -rmap patch to 2.5,
>  > the shrinkage of the struct page. Most of this code is from
>  > William Irwin and Christoph Hellwig.
>
>  Anton Blanchard did some nice benchmarks of this work a while
>  ago, and noticed that with one of the features (I think the
>  I forget which its in the l-k archives somewhere) there
>  seemed to be a noticable performance degradation.
>  Of course, this was a dbench test, so how reflective this is
>  of real world is another story..

IIRC he got a performance increase from the page->wait
removal ... but nothing too noticable either.

>  Maybe Randy Hron can throw it in with the next round of
>  kernel tests he does ?

That would be interesting, though I don't expect this
patch to change performance a lot.

It is mostly useful for machines with highmem who have
all their low memory eaten up by the mem_map[] array ;)

>  > Unfortunately I haven't managed to make 2.5.5-pre2 to boot on
>  > my machine, so I haven't been able to test this port of the
>  > patch to 2.5.
>
>  Just a complete lock up ? oops ? anything ?

It's just locking up.  Here are the last 3 lines, after that
nothing happens at all...

hdc: WDC WD84AA, ATA DISK drive
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ide1 at 0x170-0x177,0x376 on irq 15

regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
