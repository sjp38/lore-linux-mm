Date: Wed, 15 Dec 2004 00:55:49 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041214235549.GT16322@dualathlon.random>
References: <419FB4CD.7090601@ribosome.natur.cuni.cz> <1101037999.23692.5.camel@thomas> <41A08765.7030402@ribosome.natur.cuni.cz> <1101045469.23692.16.camel@thomas> <1101120922.19380.17.camel@tglx.tec.linutronix.de> <41A2E98E.7090109@ribosome.natur.cuni.cz> <1101205649.3888.6.camel@tglx.tec.linutronix.de> <41BF0F0D.4000408@ribosome.natur.cuni.cz> <20041214173858.GJ16322@dualathlon.random> <1103067018.5420.37.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1103067018.5420.37.camel@npiggin-nld.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Martin =?utf-8?Q?MOKREJ=C5=A0?= <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de, Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 15, 2004 at 10:30:18AM +1100, Nick Piggin wrote:
> Was there some swap-token (or can anyone think of any relevant)
> changes recently?

The only thing I know about recent swap-token changes, is that Andrew
fixed a bug by ignoring the token thing at priority 0, this the
early-oom failures in my queue (the VM bug was introduced sometime
before or during 2.6.9-rc). The fix is already in mainline according to
my out of sync copy of kernel CVS.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
