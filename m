Date: Wed, 19 Sep 2007 12:00:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 4/8] oom: serialize out of memory calls
In-Reply-To: <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709191159100.2241@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, David Rientjes wrote:

> Before invoking the OOM killer, a final allocation attempt with a very
> high watermark is attempted.  Serialization needs to occur at this point
> or it may be possible that the allocation could succeed after acquiring
> the lock.  If the lock is contended, the task is put to sleep and the
> allocation attempt is retried when rescheduled.

The problem with a succeeding allocation is that it takes memory 
away from the OOM killer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
