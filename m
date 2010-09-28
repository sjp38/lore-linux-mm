Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 397C46B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 17:38:02 -0400 (EDT)
Date: Tue, 28 Sep 2010 14:36:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] arch: remove __GFP_REPEAT for order-0 allocations
Message-Id: <20100928143655.4282a001.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010 03:45:10 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Order-0 allocations, including quicklist_alloc(),  are always under 
> PAGE_ALLOC_COSTLY_ORDER, so they loop endlessly in the page allocator
> already without the need for __GFP_REPEAT.

That's only true for the current implementation of the page allocator.

If we were to change the page allocator behaviour to not do that (and
we change it daily!) then all those callsites which wanted __GFP_REPEAT
behaviour will get broken.  So someone would need to go back and work
out how to unbreak them, if we remembered.

Plus there's presumably some documentary benefit in leaving the
__GFP_REPEATs in there.

Why are those __GFP_REPEATs present at those callsites?  What were
developers trying to achieve?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
