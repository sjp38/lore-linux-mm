Subject: Re: the new VMt
References: <Pine.LNX.4.21.0009261051290.2199-100000@elte.hu>
From: Jes Sorensen <jes@linuxcare.com>
Date: 26 Sep 2000 11:02:14 +0200
In-Reply-To: Ingo Molnar's message of "Tue, 26 Sep 2000 10:52:25 +0200 (CEST)"
Message-ID: <d3bsxby19l.fsf@lxplus015.cern.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Ingo" == Ingo Molnar <mingo@elte.hu> writes:

Ingo> On 26 Sep 2000, Jes Sorensen wrote:

>> 9.5KB blocks is common for people running Gigabit Ethernet with
>> Jumbo frames at least.

Ingo> yep, although this is more of a Linux limitation, the cards
Ingo> themselves are happy to DMA fragmented buffers as well. (sans
Ingo> some small penalty per new fragment.)

Hence the reason I have been pushing for the kiobufifying of the skbs ;-)
It's even more important for HIPPI with the 65280 bytes MTU.

Jes
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
