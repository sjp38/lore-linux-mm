Date: Sat, 12 May 2007 21:21:30 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-ID: <20070512192130.GA8833@one.firstfloor.org>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl> <20070511093108.495feb70.akpm@linux-foundation.org> <Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com> <20070511110522.ed459635.akpm@linux-foundation.org> <p73odkpeusf.fsf@bingen.suse.de> <20070512181254.GA331@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070512181254.GA331@tv-sign.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> This also allows us to de-uglify workqueue.c a little bit, it uses
> a home-grown cpu_populated_map.

It might be obsolete iff more and more architecture don't use NR_CPUS filled
possible_map anymore (haven't checked them all to know if it's true or not)

If not there are a couple of more optimizations that can be done, e.g.
in networking by converting more code to hotplug notifier.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
