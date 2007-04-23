Message-ID: <462C35FC.3050109@redhat.com>
Date: Mon, 23 Apr 2007 00:28:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au>
In-Reply-To: <462ACA40.8070407@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> So where is the down_write coming from in this workload, I wonder?
> Heap management? What syscalls?

Trying to answer this question, I straced the mysql threads that
showed up in top when running a single threaded sysbench workload.

There were no mmap, munmap, brk, mprotect or madvise system calls
in the trace.

MySQL has me puzzled, but it seems to have some other people
interested too.

I think I'll go play a bit with ebizzy now, to see how other
workloads are affected by our kernel changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
