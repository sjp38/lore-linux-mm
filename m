Date: Fri, 21 Sep 2007 12:13:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 0/9] oom killer serialization
In-Reply-To: <alpine.DEB.0.9999.0709210216230.6056@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709211210550.11391@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <20070921021208.e6fec547.akpm@linux-foundation.org> <alpine.DEB.0.9999.0709210216230.6056@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, David Rientjes wrote:

> This provides serialization for system-wide, mempolicy-constrained, and 
> cpuset-constrained OOM kills which was a small subset of Andrea's 24-patch 
> series posted August 22.
> 
> It replaces the following patches from Andrea:
> 	[PATCH 04 of 24] serialize oom killer
> 	[PATCH 12 of 24] show mem information only when a task is actually being killed
> 

It also replaces
	[PATCH 19 of 24] cacheline align VM_is_OOM to prevent false sharing

since locking isn't globally done with VM_is_OOM anymore.

Also, the patch
	[PATCH 17 of 24] apply the anti deadlock features only to global oom

will no longer need to move the global locking mechanism since its now 
non-existant, but the deadlock feature is still apporpriate in the 
CONSTRAINT_NONE (i.e. global) case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
