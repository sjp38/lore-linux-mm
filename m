From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 1/8] Mem Policy: Write lock mmap_sem while changing task mempolicy
Date: Thu, 6 Dec 2007 22:24:58 +0100
References: <20071206212047.6279.10881.sendpatchset@localhost> <20071206212053.6279.27183.sendpatchset@localhost>
In-Reply-To: <20071206212053.6279.27183.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712062224.58812.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@skynet.ie, eric.whitney@hp.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thursday 06 December 2007 22:20:53 Lee Schermerhorn wrote:
> PATCH/RFC 01/08 Mem Policy: Write lock mmap_sem while changing task mempolicy
> 
> Against:  2.6.24-rc2-mm1
> 
> A read of /proc/<pid>/numa_maps holds the target task's mmap_sem
> for read while examining each vma's mempolicy.  A vma's mempolicy
> can fall back to the task's policy.  However, the task could be
> changing it's task policy and free the one that the show_numa_maps()
> is examining.

But do_set_mempolicy doesn't actually modify the mempolicy. It just
replaces it using essentially Copy-on-write. 

If the numa_maps holds a proper reference count (I haven't 
checked if it does) it can keep the old unmodified one as long as it wants.

I don't think a write lock is needed.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
