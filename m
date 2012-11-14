Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 851AF6B005A
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 06:03:05 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so160983dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:03:04 -0800 (PST)
Date: Wed, 14 Nov 2012 03:03:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/4] mm, oom: ensure sysrq+f always passes valid
 zonelist
In-Reply-To: <20121114105049.GE17111@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.00.1211140254020.6949@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com> <20121114105049.GE17111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Nov 2012, Michal Hocko wrote:

> > With hotpluggable and memoryless nodes, it's possible that node 0 will
> > not be online, so use the first online node's zonelist rather than
> > hardcoding node 0 to pass a zonelist with all zones to the oom killer.
> 
> Makes sense although I haven't seen a machine with no 0 node yet.

We routinely do testing with them, actually, just by physically removing 
all memory described by the SRAT that maps to node 0.  You could do the 
same thing by making all pxms that map to node 0 to be hotpluggable in 
your memory affinity structure.  I've been bit by it one too many times so 
I always keep in mind that no single node id is guaranteed to be online 
(although at least one node is always online); hence, first_online_node is 
the solution.

> According to 13808910 this is indeed possible.
> 
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
