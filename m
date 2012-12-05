Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1D58C6B0070
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 19:24:13 -0500 (EST)
Date: Tue, 4 Dec 2012 16:24:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory
 changes
Message-Id: <20121204162411.700d4954.akpm@linux-foundation.org>
In-Reply-To: <1354666628.6733.227.camel@calx>
References: <50B8F2F4.6000508@parallels.com>
	<20121203144310.7ccdbeb4.akpm@linux-foundation.org>
	<50BD86DE.6050700@parallels.com>
	<20121204152121.e5c33938.akpm@linux-foundation.org>
	<1354666628.6733.227.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 04 Dec 2012 18:17:08 -0600
Matt Mackall <mpm@selenic.com> wrote:

> On Tue, 2012-12-04 at 15:21 -0800, Andrew Morton wrote:
> > On Tue, 04 Dec 2012 09:15:10 +0400
> > Pavel Emelyanov <xemul@parallels.com> wrote:
> > 
> > > 
> > > > Two alternatives come to mind:
> > > > 
> > > > 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
> > > >     fashion to determine which pages have been touched.
> 
> [momentarily coming out of kernel retirement for old man rant]
> 
> This is a popular interface anti-pattern.
> 
> You shouldn't use an interface that gives you huge amount of STATE to
> detect small amounts of CHANGE via manual differentiation.

I'm not sure that's what checkpoint-restart will be doing.  If we want
to determine "which pages have been touched since the last checkpoint
ten minutes ago" then that set of touched pages *is* state.  And it's
not "small"!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
