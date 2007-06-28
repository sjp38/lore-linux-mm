Date: Thu, 28 Jun 2007 13:43:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <20070628115537.56344465.pj@sgi.com>
Message-ID: <alpine.DEB.0.99.0706281341420.30133@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com> <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
 <20070628003334.1ed6da96.pj@sgi.com> <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
 <20070628020302.bb0eea6a.pj@sgi.com> <alpine.DEB.0.99.0706281104490.20980@chino.kir.corp.google.com>
 <20070628115537.56344465.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Paul Jackson wrote:

> Would you like to propose a patch, adding a per-cpuset Boolean flag
> that has inheritance properties similar to the memory_spread_* flags?
> Set at the top and inherited on cpuset creation; overridable per-cpuset.
> 
> How about calling it "oom_kill_asking_task", defaulting to 0 (the
> default you will like, not the one I will use for my customers.)
> 

That sounds like a good solution.  I certainly don't want to cause a 
regression for your customers where this change would cause the OOM killer 
to become excessively expensive.

I'd like an ack from Christoph on my posted patch that does this before 
it's merged, however, to make sure he thinks its worth the addition of yet 
another cpuset flag.

Thanks for the reviews.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
