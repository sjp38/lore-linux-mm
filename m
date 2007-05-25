Date: Fri, 25 May 2007 01:01:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
Message-Id: <20070525010112.2c5754ac.akpm@linux-foundation.org>
In-Reply-To: <1180079479.7348.33.camel@twins>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	<1180076565.7348.14.camel@twins>
	<20070525001812.9dfc972e.akpm@linux-foundation.org>
	<1180077810.7348.20.camel@twins>
	<20070525002829.19deb888.akpm@linux-foundation.org>
	<1180078590.7348.27.camel@twins>
	<20070525004808.84ae5cf3.akpm@linux-foundation.org>
	<1180079479.7348.33.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 09:51:19 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

But why?  It might make the VM suck.  Or swap more.  Or go oom.

I don't know how to justify merging this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
