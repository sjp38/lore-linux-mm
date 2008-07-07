Date: Mon, 07 Jul 2008 13:48:32 -0700 (PDT)
Message-Id: <20080707.134832.189558582.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080707193008.17795d61@the-village.bc.nu>
References: <20080707191359.11f6297f@the-village.bc.nu>
	<48726734.7080601@garzik.org>
	<20080707193008.17795d61@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Mon, 7 Jul 2008 19:30:08 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: alan@lxorguk.ukuu.org.uk
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I don't see why it should be David's job to add every conceivable feature
> to the code.

David's changes prevent something from working, which works today.

Usually we refer to that as a regression.

And usually, we rely on the patch author to fix regressions they add,
and failing that we revert their work.

Bringing up this SATA scarecrow and trying to make Jeff look
inconsistent is not winning your arguments any extra points.
Especially not with me.

You also mentioned something about how similar arguments as ours
were made when modules were proposed as a feature.  Well, I can
say only two things about that:

1) I could still build a static kernel image and use it as-is after
   the changes to support modules were added to the kernel.  In fact I
   still largely do not use modules at all during my own kernel work.

   This is completely unlike what David is doing here, where the
   previous status quo will cease working.

2) You cannot deny the fine mess we have with proprietary modules and
   such these days.  It has been quite the pandora's box over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
