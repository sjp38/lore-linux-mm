Date: Tue, 20 Aug 2002 06:55:35 -0600 (MDT)
From: Thunder from the hill <thunder@lightweight.ods.org>
Subject: Re: [BUG] 2.5.30 swaps with no swap device mounted!!
In-Reply-To: <20020819105520.GK18350@holomorphy.com>
Message-ID: <Pine.LNX.4.44.0208200655040.3234-100000@hawkeye.luckynet.adm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 19 Aug 2002, William Lee Irwin III wrote:
> Due to the natural slab shootdown laziness issues, I turned off swap.
> The kernel reported that it had successfully unmounted the swap device,
> and for several days ran without it. Tonight, it went 91MB into swap
> on the supposedly unmounted swap device!

It might be interesting to see what happens if you unplug the swap device 
after umounting.

			Thunder
-- 
--./../...-/. -.--/---/..-/.-./..././.-../..-. .---/..-/.../- .-
--/../-./..-/-/./--..-- ../.----./.-../.-.. --./../...-/. -.--/---/..-
.- -/---/--/---/.-./.-./---/.--/.-.-.-
--./.-/-.../.-./.././.-../.-.-.-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
