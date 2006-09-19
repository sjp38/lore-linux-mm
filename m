Date: Tue, 19 Sep 2006 14:28:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.63.0609191401360.8253@chino.corp.google.com>
Message-ID: <Pine.LNX.4.64.0609191426560.7480@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
 <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
 <Pine.LNX.4.64.0609191224560.6976@schroedinger.engr.sgi.com>
 <Pine.LNX.4.63.0609191401360.8253@chino.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, David Rientjes wrote:

> If the memory from existing nodes are used to create the new node, then 
> any tasks assigned to that parent node through cpusets will be degraded.  
> Not a problem since the user would be aware of this affect on node 
> creation, but you'd need callback_mutex and task_lock for each task 
> within the parent node and possibly rcu_read_lock for the mems_generation.

Paul has already cpuset code in mm that supports exactly this situation. 
He can probably explain the locking which as far as I can tell is much 
simpler than you anticipate.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
