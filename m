Date: Mon, 29 Jan 2007 10:15:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/14] Concurrent Page Cache
In-Reply-To: <1170093944.6189.192.camel@twins>
Message-ID: <Pine.LNX.4.64.0701291013530.29254@schroedinger.engr.sgi.com>
References: <20070128131343.628722000@programming.kicks-ass.net>
 <Pine.LNX.4.64.0701290918260.28330@schroedinger.engr.sgi.com>
 <1170093944.6189.192.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, Peter Zijlstra wrote:

> Ladder locking would end up:
> 
> lock A0
> lock B1
> unlock A0 -> a new operation can start
> lock C2
> unlock B1
> lock D5
> unlock C2
> ** we do stuff to D5
> unlock D5
> 

Instead of taking one lock we would need to take 4? Wont doing so cause 
significant locking overhead? We probably would want to run some 
benchmarks. Maybe disable the scheme for systems with a small number of 
processors?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
