Date: Thu, 20 Apr 2006 16:54:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Page Cache Policy V0.0 1/5 add offset arg to
 migrate_pages_to()
In-Reply-To: <1145565667.5214.36.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604201652000.19049@schroedinger.engr.sgi.com>
References: <1145565667.5214.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2006, Lee Schermerhorn wrote:

> Page Cache Policy V0.0 1/5 add offset arg to migrate_pages_to()
> 
> This patch adds a page offset arg to migrate_pages_to() for
> use in selecting nodes from which to allocate for regions with
> interleave policy.   This is needed to calculate the correct
> node for shmem and generic mmap()ed files using the shared
> policy infrastructure [subsequent patches]

Why do we not need this patch? Is it not possible to
calculate the interleave node from the inode offset? This is only 
necessary for the case in which no vma is available right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
