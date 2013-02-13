Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 5FD716B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:00:46 -0500 (EST)
Date: Tue, 12 Feb 2013 19:59:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 53501] New: Duplicated MemTotal with different values
Message-Id: <20130212195929.7cd2e597.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com>
References: <bug-53501-27@https.bugzilla.kernel.org/>
	<20130212165107.32be0c33.akpm@linux-foundation.org>
	<alpine.DEB.2.02.1302121742370.5404@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>, sworddragon2@aol.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, 12 Feb 2013 17:45:42 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> > > The installed memory on my system is 16 GiB. /proc/meminfo is showing me
> > > "MemTotal:       16435048 kB" but /sys/devices/system/node/node0/meminfo is
> > > showing me "Node 0 MemTotal:       16776380 kB".
> > > 
> > > My suggestion: MemTotal in /proc/meminfo should be 16776380 kB too. The old
> > > value of 16435048 kB could have its own key "MemAvailable".
> > 
> > hm, mine does that too.  A discrepancy between `totalram_pages' and
> > NODE_DATA(0)->node_present_pages.
> > 
> > I don't know what the reasons are for that but yes, one would expect
> > the per-node MemTotals to sum up to the global one.
> > 
> 
> I'd suspect it has something to do with 9feedc9d831e ("mm: introduce new 
> field "managed_pages" to struct zone") and 3.8 would be the first kernel 
> release with this change.  Is it possible to try 3.7 or, better yet, with 
> this patch reverted?

My desktop machine at google in inconsistent, as is the 2.6.32-based
machine, so it obviously predates 9feedc9d831e.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
