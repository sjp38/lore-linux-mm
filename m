Date: Fri, 20 Apr 2007 23:35:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: slab allocators: Remove multiple alignment specifications.
In-Reply-To: <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704202335280.11938@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
 <20070420223727.7b201984.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
 <20070420231129.9252ca67.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704202330440.11938@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007, Christoph Lameter wrote:

> Hmmmm... Revoke.c has another copy of these fs constructor flag checks 
> that I fixed earlier.

And another one

Index: linux-2.6.21-rc7/fs/proc/inode.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/proc/inode.c	2007-04-20 23:35:07.000000000 -0700
+++ linux-2.6.21-rc7/fs/proc/inode.c	2007-04-20 23:35:19.000000000 -0700
@@ -109,8 +109,7 @@ static void init_once(void * foo, struct
 {
 	struct proc_inode *ei = (struct proc_inode *) foo;
 
-	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
-	    SLAB_CTOR_CONSTRUCTOR)
+	if (flags & SLAB_CTOR_CONSTRUCTOR)
 		inode_init_once(&ei->vfs_inode);
 }
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
