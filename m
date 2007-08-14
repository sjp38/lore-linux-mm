Date: Tue, 14 Aug 2007 22:34:57 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Message-ID: <20070814203457.GB22202@one.firstfloor.org>
References: <20070814153021.446917377@sgi.com> <20070814153501.766137366@sgi.com> <p73vebhnauo.fsf@bingen.suse.de> <Pine.LNX.4.64.0708141209270.29498@schroedinger.engr.sgi.com> <1187121951.5337.4.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187121951.5337.4.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> A much simpler approach to this seems to use threaded interrupts like
> -rt does.

Then the interrupt could potentially stay blocked for very long
waiting for process context to finish its work. Also not good.
Essentially it would be equivalent to cli/sti for interrupts
that need to free memory.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
