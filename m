Message-ID: <39E22725.1F053820@kalifornia.com>
Date: Mon, 09 Oct 2000 13:14:30 -0700
From: David Ford <david@kalifornia.com>
Reply-To: david+validemail@kalifornia.com
MIME-Version: 1.0
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
References: <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu> <39E21CCB.61AC1EBE@kalifornia.com> <20001009215809.I19583@athlon.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: mingo@elte.hu, Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> On Mon, Oct 09, 2000 at 12:30:20PM -0700, David Ford wrote:
> > Init should only get killed if it REALLY is taking a lot of memory.  On a 4 or 8meg
>
> Init should never get killed. Killing init can be compared to destroy the TCP
> stack. Some app can keep to run right for some minute until they run socket()
> and then they will hang. Same with init, some task may still run right for
> some time but the machine will die eventually. We simply must not pass the
> point of not return or we're buggy and after the bug triggered we have to force
> the user to reboot the machine as only way to recover.

After 1/2 a second of deep reflection, I concur.  Pretty much all interactive processes
will die immediately.  That just doesn't make for happy penguins.

-d

--
      "There is a natural aristocracy among men. The grounds of this are
      virtue and talents", Thomas Jefferson [1742-1826], 3rd US President



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
