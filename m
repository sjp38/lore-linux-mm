Date: Thu, 17 Jan 2002 22:05:52 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] rmap VM 11c
In-Reply-To: <Pine.LNX.3.96.1020117185411.4089A-100000@gatekeeper.tmr.com>
Message-ID: <Pine.LNX.4.33L.0201172204080.32617-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2002, Bill Davidsen wrote:

> >            http://surriel.com/patches/2.4/2.4.17-rmap-11c
> > and        http://linuxvm.bkbits.net/

> Rik, I tried a simple test, building a kernel in a 128M P-II-400, and
> when the load average got up to 50 or so the system became slow;-) On
> the other hand it was still usable for most normal things other then
> incoming mail which properly blocks at LA>10 or so.

Hehehe, when the load average is 50 only 2% of the CPU is available
for you. With that many gccs you're also under a memory squeeze with
128 MB of RAM, so it's no big wonder things got slow. ;)

I'm happy to hear the system was still usable, though.

> I'll be trying it on a large machine tomorrow, but it at least looks
> stable. In real life no sane person would do that, would they? Make
> with a nice -10 was essentially invisible.

Neat ...

> Maybe tomorrow the lateest -aa kernel on the same machine, with and
> without my own personal patch.

Looking forward to the results.

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
