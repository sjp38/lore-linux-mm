Date: Mon, 22 Jul 2002 17:03:07 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
In-Reply-To: <1027366468.5170.26.camel@plars.austin.ibm.com>
Message-ID: <Pine.LNX.4.44L.0207221657460.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Jul 2002, Paul Larson wrote:

> Encountered this first with Linux-2.5.25+rmap and it looks like the
> problem also slipped into 2.5.27.  The same machine boots fine with a
> vanilla 2.5.25 or 2.5.26, but gets this on boot with rmap.  The machine
> is an 8-way PIII-700.

Bill Irwin has told me about a rare bug with exec() mapping
garbage into the address space of a process, which might
trigger this bug check the next time that process exec()s.

I've gotten two reports of this bug now, but have no idea
what particular combination of hardware / compiler / config
triggers the bug. The rmap code seems to have survived akpm's
stress tests so it's probably not a simple bug to track down ;/

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
