Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1FN2rVp019283
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 15:02:54 -0800
Message-ID: <42127C38.9000406@sgi.com>
Date: Tue, 15 Feb 2005 16:48:24 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: manual page migration -- issues
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The following is an attempt to summarize the issues that have
been raised thus far in this discussion.  I'm hoping that this
list can help us resolve the issues in a (somewhat) organized
manner:

(1)  Should there be a new API or should/can the migration functionality
      be folded under the NUMA API?

(2)  If we decide to make a new API, then what parameters should
      that system call take?  Proposals have been made for all of
      the following:

      -- pid, va_start, va_end, count, old_nodes, new_nodes
      -- pid, va_start, va_end, old_node_mask, new_node_mask
      -- pid, va_start, va_end, old_node, new_node
      -- same variations as above without the va_start/end arguments

(2)  If we make a new API, how does that new API interact with the
      NUMA API?
      -- e. g.what happens when we migrate a VMA that has a mempolicy
         associated with it?

(3)  If we make a new API, how does this API interact with the rest
      of the VM system.  For example, when we migrate part of a VMA
      do we split the VMA or not?  (See also (4) below since if we
      decide that the migration interface needs to be able to migrate
      processes without stopping them, the whole concept of talking
      about such ephemeral things as VMAs becomes pointless.)

(4)  How general of a migration model are we supporting?
      -- migration where old and new set of nodes might not be disjoint
      -- migration of general processes (without suspension) or just
         of suspended processes
      -- how general of a migration model is necessary to get sufficient
         users (more than SGI, say) to increase the chances of getting
         the facility merged into the kernel.

(5)  How do we determine what vma's to migrate?   (Subquestion:  Is
      this done by the kernel or in user space?)
      -- original idea:  reference counts in /proc/pid/maps
      -- newer idea: exclusion lists either set by marking the
         file in some special way or by an explicit list
      -- if we mark files as non-migratable, where is this information
         stored?

(6)  How does the migration API (in whatever form it takes) interact
      with cpusets?

So first off, is this the complete list of issues?  Can anyone suggest
an issue that isn't covered here?
-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
