Date: Wed, 16 May 2007 16:40:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] scalable rw_mutex
In-Reply-To: <20070516162829.23f9b1c4.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705161639010.12688@schroedinger.engr.sgi.com>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl>
 <20070511093108.495feb70.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
 <20070511110522.ed459635.akpm@linux-foundation.org> <p73odkpeusf.fsf@bingen.suse.de>
 <20070512110624.9ac3aa44.akpm@linux-foundation.org>
 <20070516162829.23f9b1c4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, Andrew Morton wrote:

> (I hope.  Might have race windows in which the percpu_counter_sum() count is
> inaccurate?)

The question is how do these race windows affect the locking scheme?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
