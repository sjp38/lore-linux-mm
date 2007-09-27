Date: Wed, 26 Sep 2007 23:15:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
In-Reply-To: <20070926144748.768efcbe.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709262313440.20560@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com> <20070926130616.f16446fd.akpm@linux-foundation.org> <alpine.DEB.0.9999.0709261337080.23401@chino.kir.corp.google.com> <20070926144748.768efcbe.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: andrea@suse.de, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Sep 2007, Andrew Morton wrote:

> > It can be gathered by other means, yes, but not at the time of OOM nor 
> > immediately before a task is killed.  This tasklist dump is done very 
> > close to the OOM kill and it represents the per-task memory state, whether 
> > system or cgroup, that triggered that event.
> 
> OK, that's useful.  But your changelog was completely wrong - it implies
> that this sysctl _causes_ the dump, rather than stating that the sysctl
> _enables_ an oom-kill-time dump:
> 

Oops, that does sound confusing.  I'll reword the changelog and the 
addition to Documentation/sysctl/vm.txt so it's not ambiguous.

Sorry for the confusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
