Date: Mon, 7 Jan 2008 11:11:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01 of 11] limit shrink zone scanning
In-Reply-To: <0d6cfa8fbffe9d3593ff.1199326147@v2.random>
Message-ID: <Pine.LNX.4.64.0801071110120.23617@schroedinger.engr.sgi.com>
References: <0d6cfa8fbffe9d3593ff.1199326147@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jan 2008, Andrea Arcangeli wrote:

> Assume two tasks adds to nr_scan_*active at the same time (first line of the
> old buggy code), they'll effectively double their scan rate, for no good
> reason. What can happen is that instead of scanning nr_entries each, they'll
> scan nr_entries*2 each. The more CPUs the bigger the race and the higher the
> multiplication effect and the harder it will be to detect oom. This puts a cap
> on the amount of work that it makes sense to do in case the race triggers.

Looks like a workaround. Would it be cleaner to make the scan 
counters local variables and only them when the scan is complete?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
