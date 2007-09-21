Date: Fri, 21 Sep 2007 02:21:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 0/9] oom killer serialization
In-Reply-To: <20070921021208.e6fec547.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.0.9999.0709210216230.6056@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <20070921021208.e6fec547.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, Andrew Morton wrote:

> On Thu, 20 Sep 2007 13:23:13 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > Third version of the OOM serialization patchset. 
> 
> What's the relationship between this patch series and Andrea's monster
> oomkiller patchset?  Looks like teeny-subset-plus-other-stuff?
> 

This provides serialization for system-wide, mempolicy-constrained, and 
cpuset-constrained OOM kills which was a small subset of Andrea's 24-patch 
series posted August 22.

It replaces the following patches from Andrea:
	[PATCH 04 of 24] serialize oom killer
	[PATCH 12 of 24] show mem information only when a task is actually being killed

And the following patches from me:
	[PATCH 21 of 24] select process to kill for cpusets
	[PATCH 22 of 24] extract select helper function
	[PATCH 23 of 24] serialize for cpusets
	[PATCH 24 of 24] add oom_kill_asking_task flag

> Are all attributions on all those patches appropriately set?
> 

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
