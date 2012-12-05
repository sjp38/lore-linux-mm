Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BA3AF6B0072
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 19:39:01 -0500 (EST)
Message-ID: <1354667937.6733.233.camel@calx>
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
From: Matt Mackall <mpm@selenic.com>
Date: Tue, 04 Dec 2012 18:38:57 -0600
In-Reply-To: <20121204162411.700d4954.akpm@linux-foundation.org>
References: <50B8F2F4.6000508@parallels.com>
	 <20121203144310.7ccdbeb4.akpm@linux-foundation.org>
	 <50BD86DE.6050700@parallels.com>
	 <20121204152121.e5c33938.akpm@linux-foundation.org>
	 <1354666628.6733.227.camel@calx>
	 <20121204162411.700d4954.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>

On Tue, 2012-12-04 at 16:24 -0800, Andrew Morton wrote:
> On Tue, 04 Dec 2012 18:17:08 -0600
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On Tue, 2012-12-04 at 15:21 -0800, Andrew Morton wrote:
> > > On Tue, 04 Dec 2012 09:15:10 +0400
> > > Pavel Emelyanov <xemul@parallels.com> wrote:
> > > 
> > > > 
> > > > > Two alternatives come to mind:
> > > > > 
> > > > > 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
> > > > >     fashion to determine which pages have been touched.
> > 
> > [momentarily coming out of kernel retirement for old man rant]
> > 
> > This is a popular interface anti-pattern.
> > 
> > You shouldn't use an interface that gives you huge amount of STATE to
> > detect small amounts of CHANGE via manual differentiation.
> 
> I'm not sure that's what checkpoint-restart will be doing.  If we want
> to determine "which pages have been touched since the last checkpoint
> ten minutes ago" then that set of touched pages *is* state.  And it's
> not "small"!

Yeah, there is definitely a middle-ground here between "I want
high-frequency updates" and "I want to see the whole picture". 
The filesystem analogy is backups: we don't have any good way to say
"find me all files changed since yesterday" short of "find all files".
The closest thing is explicit snapshotting.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
