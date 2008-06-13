Date: Fri, 13 Jun 2008 01:42:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080613014234.ddd01184.akpm@linux-foundation.org>
In-Reply-To: <485230EA.2040808@bull.net>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<48521BC8.5080801@bull.net>
	<485230EA.2040808@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 10:33:46 +0200 Nadia Derbey <Nadia.Derbey@bull.net> wrote:

> > Sorry for answering so late (I only saw you e-mail yesterday afternoon).
> > I have just run msgctl08, setting msgmni to 1722 and turning on the SLAB 
> > debug:
> > 
> > CONFIG_SLAB=y
> > CONFIG_SLABINFO=y
> > CONFIG_DEBUG_SLAB=y
> > CONFIG_DEBUG_SLAB_LEAK=y
> > 
> > kernel: linux-2.6.26-rc5-mm1
> > ltp: ltp-full-20080430
> > 
> > But I could not reproduce the bug.
> > 
> > Will try to investigate more.
> > 
> 
> Same result with 2.6.26-rc6.

erk.  It'll make me a week to bisect this.  I suppose I can plod away
at it in the background, but I won't be able to do that until the end
of this month.

> I saw from your config file that you're running a 2.6.26-rc2. Will try 
> with that one.

No, that was just when I last checked in that machine's .config file. 
It was yesterday's mainline, with that .config and `make oldconfig'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
