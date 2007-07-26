Date: Wed, 25 Jul 2007 23:15:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/4] oom: extract deadlock helper function
In-Reply-To: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.99.0707252311570.12071@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jun 2007, David Rientjes wrote:

> Extracts the jiffies comparison operation, the assignment of the
> last_tif_memdie actual, and diagnostic message to its own function.
> 

Andrew, can you give me an update on where Andrea and I's patchsets for 
the OOM killer stand for inclusion in -mm?  Andrea's were posted June 
8-13 and mine were posted June 27-28 to linux-mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
