Message-Id: <199912092332.AAA27593@cave.bitwizard.nl>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912100021250.10946-100000@chiara.csoma.elte.hu>
 from Ingo Molnar at "Dec 10, 1999 00:24:27 am"
Date: Fri, 10 Dec 1999 00:32:01 +0100 (MET)
From: R.E.Wolff@BitWizard.nl (Rogier Wolff)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "William J. Earl" <wje@cthulhu.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> yep, if eg. an fsck happened before modules are loaded then RAM is filled
> up with the buffer-cache. The best guarantee is to compile such drivers
> into the kernel.

My ISDN drivers don't start up correctly after an fsck. 

What I should do is:

hogmem 8 &
sleep 5
kill %1

before trying to start the ISDN drivers. (This is on a 16M machine). 

				Roger.

-- 
** R.E.Wolff@BitWizard.nl ** http://www.BitWizard.nl/ ** +31-15-2137555 **
*-- BitWizard writes Linux device drivers for any device you may have! --*
 "I didn't say it was your fault. I said I was going to blame it on you."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
