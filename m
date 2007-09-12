Date: Wed, 12 Sep 2007 05:04:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04 of 24] serialize oom killer
Message-Id: <20070912050447.2722f4dc.akpm@linux-foundation.org>
In-Reply-To: <20070912050205.a6b243a2.akpm@linux-foundation.org>
References: <patchbomb.1187786927@v2.random>
	<871b7a4fd566de081120.1187786931@v2.random>
	<20070912050205.a6b243a2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 05:02:05 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	up(&OOM_lock);
> > +}
> 
> Please use mutexes, not semaphores.  I'll make this change.

gargh, shit, OOM_lock is all over the patch series.

Is there some reason why it had to be a semaphore?  Does it get upped by
tasks which didn't down it?  Does the semaphore counting feature get used?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
