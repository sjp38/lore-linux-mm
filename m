Date: Fri, 11 May 2007 11:05:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] scalable rw_mutex
Message-Id: <20070511110522.ed459635.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
References: <20070511131541.992688403@chello.nl>
	<20070511132321.895740140@chello.nl>
	<20070511093108.495feb70.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007 10:07:17 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 11 May 2007, Andrew Morton wrote:
> 
> > yipes.  percpu_counter_sum() is expensive.
> 
> Capable of triggering NMI watchdog on 4096+ processors?

Well.  That would be a millisecond per cpu which sounds improbable.  And
we'd need to be calling it under local_irq_save() which we presently don't.
And nobody has reported any problems against the existing callsites.

But it's no speed demon, that's for sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
