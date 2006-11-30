Date: Wed, 29 Nov 2006 20:13:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to
 userspace
In-Reply-To: <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611292011540.19628@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <20061129033826.268090000@menage.corp.google.com>  <456D23A0.9020008@yahoo.com.au>
 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Paul Menage wrote:

> Quite possibly - I don't have a strong feeling for exactly where the
> code should go. There's existing code (sys_migrate_pages) that uses
> the migration mechanism that's in mm/mempolicy.c rather than
> migrate.c, and this was a pretty simple function to write.

Plus there is another mechanism in mm/migrate.c that also uses the 
migration mechanism.

> We don't need to expose the raw "priority" value, but it would be
> really nice for user space to be able to specify how hard the kernel
> should try to free some memory.

Would it not be sufficient to specify that in the number of attempts like
already provided by the page migration scheme?

> Then each job can specify a "reclaim pressure", i.e. how much
> back-pressure should be applied to its allocated memory, so you can
> get a good idea of how much memory the job is really using for a given
> level of performance. High reclaim pressure results in a smaller
> working set but possibly more paging in from disk; low reclaim
> pressure uses more memory but gets higher performance.

Reclaim? I thought you wanted to migrate memory of a node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
