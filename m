Date: Tue, 14 Dec 2004 18:38:58 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041214173858.GJ16322@dualathlon.random>
References: <419F2AB4.30401@ribosome.natur.cuni.cz> <1100957349.2635.213.camel@thomas> <419FB4CD.7090601@ribosome.natur.cuni.cz> <1101037999.23692.5.camel@thomas> <41A08765.7030402@ribosome.natur.cuni.cz> <1101045469.23692.16.camel@thomas> <1101120922.19380.17.camel@tglx.tec.linutronix.de> <41A2E98E.7090109@ribosome.natur.cuni.cz> <1101205649.3888.6.camel@tglx.tec.linutronix.de> <41BF0F0D.4000408@ribosome.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <41BF0F0D.4000408@ribosome.natur.cuni.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin =?utf-8?Q?MOKREJ=C5=A0?= <mmokrejs@ribosome.natur.cuni.cz>
Cc: tglx@linutronix.de, Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2004 at 05:04:29PM +0100, Martin MOKREJA  wrote:
> I see the machine a lot less responsive when it starts swapping
> compared to 2.6.10-rc2-mm3. For example, just moving mouse between
> windows takes some 10-12 seconds to fvwm2 to re-focus to another xterm
> window.

I don't know exactly what's the issue here, but the oom fixes we
developed cannot change anything until you see the first printk in the
logs (the printk tells the admin the machine reached oom).

So slowdowns during paging can be discussed separately from the oom
killer issues.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
