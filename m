Date: Mon, 11 Jun 2007 09:04:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 10 of 16] stop useless vm trashing while we wait the
 TIF_MEMDIE task to exit
In-Reply-To: <20070609140552.GA7130@v2.random>
Message-ID: <Pine.LNX.4.64.0706110901530.15326@schroedinger.engr.sgi.com>
References: <24250f0be1aa26e5c6e3.1181332988@v2.random>
 <Pine.LNX.4.64.0706081446200.3646@schroedinger.engr.sgi.com>
 <20070609015944.GL9380@v2.random> <Pine.LNX.4.64.0706082000370.5145@schroedinger.engr.sgi.com>
 <20070609140552.GA7130@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2007, Andrea Arcangeli wrote:

> I just showed the global flag that is being checked. TIF_MEMDIE
> affects the whole system, not just your node-constrained allocating

TIF_MEMDIE affects the task that attempted to perform an constrained 
allocation. The effects are global for that task but there are not as 
severe as setting a global OOM flag!

> Amittedly my fixes made things worse for your "local" oom killing, but
> your code was only apparently "local" because TIF_MEMDIE is a _global_
> flag in the mainline kernel. So again, I'm very willing to improve the

TIF_MEMDIE is confined to a process.

> local one. I didn't look into the details of the local oom killing yet
> (exactly because it wasn't so local in the first place) but it may be
> enough to set VM_is_OOM only for tasks that are not being locally
> killed and then those new changes will automatically prevent
> TIF_MEMDIE being set on a local-oom to affect the global-oom event.

TIF_MEMDIE must be set in order for the task to die properly even if its a 
constrained allocation because TIF_MEMDIE relaxes the constraints so that 
the task can terminate.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
