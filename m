Date: Wed, 28 Aug 2002 07:08:50 -0600 (MDT)
From: Thunder from the hill <thunder@lightweight.ods.org>
Subject: Re: [BUG] 2.5.30 swaps with no swap device mounted!!
In-Reply-To: <20020827135421.A39@toy.ucw.cz>
Message-ID: <Pine.LNX.4.44.0208280708020.3234-100000@hawkeye.luckynet.adm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 27 Aug 2002, Pavel Machek wrote:
> > It might be interesting to see what happens if you unplug the swap device 
> > after umounting.
> 
> In the same way it might be interesting to see what happens if you put
> cigarette into gasoline tank?

Well, you never know what unregistering does. It might happen to be 
ignored for swap, once unregistered.

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
