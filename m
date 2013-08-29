Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2E9736B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 08:11:02 -0400 (EDT)
Date: Thu, 29 Aug 2013 13:10:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130829121055.GE22421@suse.de>
References: <20120307180852.GE17697@suse.de>
 <20130823130332.GY31370@twins.programming.kicks-ass.net>
 <20130823181546.GA31370@twins.programming.kicks-ass.net>
 <20130829092828.GB22421@suse.de>
 <20130829094342.GX10002@twins.programming.kicks-ass.net>
 <20130829105656.GD22421@suse.de>
 <20130829111419.GA10002@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130829111419.GA10002@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Thu, Aug 29, 2013 at 01:14:19PM +0200, Peter Zijlstra wrote:
> > I intended to say nr_node_ids, the same size as buffers such as the
> > task_numa_buffers. If we ever return a nid > nr_node_ids here then
> > task_numa_fault would corrupt memory. However, it should be possible for
> > node_weight to exceed nr_node_ids except maybe during node hot-remove so
> > it's not the problem.
> 
> The nodemask situation seems somewhat more confused than the cpumask
> case; how would we ever return a nid > nr_node_ids? Corrupt nodemask?
> 

ARGH. I meant impossible. The exact bloody opposite of what I wrote.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
