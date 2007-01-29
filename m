Date: Mon, 29 Jan 2007 09:11:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 11/14] atomic_ulong_t
In-Reply-To: <20070128132437.299596000@programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0701290910060.28330@schroedinger.engr.sgi.com>
References: <20070128131343.628722000@programming.kicks-ass.net>
 <20070128132437.299596000@programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jan 2007, Peter Zijlstra wrote:

> provide an unsigned long atomic type.

Is this really necessary? We have no atomic_uint_t type either.

Could you use atomic_long_t instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
