Date: Tue, 26 Sep 2000 10:52:25 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VMt
In-Reply-To: <d3g0mny2cv.fsf@lxplus015.cern.ch>
Message-ID: <Pine.LNX.4.21.0009261051290.2199-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jes Sorensen <jes@linuxcare.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 26 Sep 2000, Jes Sorensen wrote:

> 9.5KB blocks is common for people running Gigabit Ethernet with Jumbo
> frames at least.

yep, although this is more of a Linux limitation, the cards themselves are
happy to DMA fragmented buffers as well. (sans some small penalty per new
fragment.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
