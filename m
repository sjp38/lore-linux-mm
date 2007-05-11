Date: Fri, 11 May 2007 10:07:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] scalable rw_mutex
In-Reply-To: <20070511093108.495feb70.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705111006470.32716@schroedinger.engr.sgi.com>
References: <20070511131541.992688403@chello.nl> <20070511132321.895740140@chello.nl>
 <20070511093108.495feb70.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007, Andrew Morton wrote:

> yipes.  percpu_counter_sum() is expensive.

Capable of triggering NMI watchdog on 4096+ processors?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
