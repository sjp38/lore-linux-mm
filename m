Date: Thu, 26 Jul 2007 00:29:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/4] oom: extract deadlock helper function
In-Reply-To: <20070725232535.20b6032e.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.99.0707260027090.15881@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0707252311570.12071@chino.kir.corp.google.com>
 <20070725232535.20b6032e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Andrew Morton wrote:

> If you have time, what would help heaps would be if you could adopt
> Andrea's patches and then maintain those and yours as a single coherent
> patchset.  Refresh, retest and squirt them all at me?
> 
> It'll take a lot of testing to test those things, and I haven't started to
> think about how we set about that.
> 

Sure, I'll actively test all the patches collectively as much as possible 
and then run them by the community again.  Thanks for the update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
