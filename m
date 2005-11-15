Date: Tue, 15 Nov 2005 14:29:54 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Add NUMA policy support for huge pages.
In-Reply-To: <eada2a070511151419j5d94ec55xb36c6ae7d17ea30a@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0511151429260.11270@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511151342310.10995@schroedinger.engr.sgi.com>
 <eada2a070511151419j5d94ec55xb36c6ae7d17ea30a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Pepper <lnxninja@us.ibm.com>
Cc: akpm@osdl.org, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, ak@suse.de, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Tim Pepper wrote:

> On 11/15/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> > +/* Caculate a node number for interleave */
>       ^^^^^
> Calculate even...

Fix:


Index: linux-2.6.14-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.14-mm2.orig/mm/mempolicy.c	2005-11-15 14:27:49.000000000 -0800
+++ linux-2.6.14-mm2/mm/mempolicy.c	2005-11-15 14:28:32.000000000 -0800
@@ -1005,7 +1005,7 @@ static unsigned offset_il_node(struct me
 	return nid;
 }
 
-/* Caculate a node number for interleave */
+/* Determine a node number for interleave */
 static inline unsigned interleave_nid(struct mempolicy *pol,
 		 struct vm_area_struct *vma, unsigned long addr, int shift)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
