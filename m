Date: Wed, 12 Sep 2007 15:34:03 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 23 of 24] serialize for cpusets
Message-ID: <20070912133403.GI21600@v2.random>
References: <patchbomb.1187786927@v2.random> <a3d679df54ebb1f977b9.1187786950@v2.random> <20070912061003.39506e07.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912061003.39506e07.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 06:10:03AM -0700, Andrew Morton wrote:
> > +void cpuset_clear_oom(struct task_struct *task)
> > +{
> > +	task_lock(task);
> > +	clear_bit(CS_OOM, &task->cpuset->flags);
> > +	task_unlock(task);
> > +}
> 
> Seems strange to do a spinlock around a single already-atomic bitop?

The CS_OOM information for us is serialized by the task_lock. But I
assume flags can change also outside of the task_lock for other usages
hence the need of clear_bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
