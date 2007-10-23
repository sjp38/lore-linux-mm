Date: Tue, 23 Oct 2007 09:23:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
 Policy
In-Reply-To: <1193156105.5859.28.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710230922270.18445@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
 <20071012154918.8157.26655.sendpatchset@localhost>
 <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0710151226330.26753@schroedinger.engr.sgi.com>
 <1193156105.5859.28.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Tue, 23 Oct 2007, Lee Schermerhorn wrote:

> Christoph:  just getting back to this.  You sent two messages commented
> about this patch.  I'm not sure whether this one supercedes the previous
> one or adds to it.   So, I'll address the points in your other comment
> separately.

It supersedes one earlier comment.

> Re:  this patch:  I can see how we need to grab the mmap_sem during
> do_set_mempolicy() to coordinate with the numa_maps display.  However,
> shouldn't we use {down|up}_write() here to obtain exclusive access with
> respect to numa_maps ?

Right. We must obtain a writelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
