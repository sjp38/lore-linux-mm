Date: Sat, 12 May 2007 11:11:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070512111100.86ae13f6.akpm@linux-foundation.org>
In-Reply-To: <20070512110624.9ac3aa44.akpm@linux-foundation.org>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
	<20070511093108.495feb70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
	<20070511110522.ed459635.akpm@linux-foundation.org>
	<p73odkpeusf.fsf@bingen.suse.de>
	<20070512110624.9ac3aa44.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 12 May 2007 11:06:24 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> We could put a cpumask in percpu_counter, initialise it to
> cpu_possible_map.  Then, those callsites which have hotplug notifiers can
> call into new percpu_counter functions which clear and set bits in that
> cpumask and which drain percpu_counter.counts[cpu] into
> percpu_counter.count.
> 
> And percpu_counter_sum() gets taught to do for_each_cpu_mask(fbc->cpumask).

Perhaps we could have a single cpu hotplug notifier in the percpu_counter
library.  Add register/deregister functions to the percpu_counter API so
that all percpu_counters in the machine can be linked together.

One _could_ just register and deregister the counters in
percpu_counter_init() and percpu_counter_destroy(), but perhaps that
wouldn't suit all callers, dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
