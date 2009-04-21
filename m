Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EE3846B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:44:51 -0400 (EDT)
Subject: [Patch] mm tracepoints update
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-0npnriLYuljgwpaUBTnD"
Date: Tue, 21 Apr 2009 18:45:15 -0400
Message-Id: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, mingo@elte.hu, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>


--=-0npnriLYuljgwpaUBTnD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I've cleaned up the mm tracepoints to track page allocation and
freeing, various types of pagefaults and unmaps, and critical page
reclamation routines.  This is useful for debugging memory allocation
issues and system performance problems under heavy memory loads.


----------------------------------------------------------------------


# tracer: mm
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         pdflush-624   [004]   184.293169: wb_kupdate:
mm_pdflush_kupdate count=3e48
         pdflush-624   [004]   184.293439: get_page_from_freelist:
mm_page_allocation pfn=447c27 zone_free=1940910
        events/6-33    [006]   184.962879: free_hot_cold_page:
mm_page_free pfn=44bba9
      irqbalance-8313  [001]   188.042951: unmap_vmas:
mm_anon_userfree mm=ffff88044a7300c0 address=7f9a2eb70000 pfn=24c29a
             cat-9122  [005]   191.141173: filemap_fault:
mm_filemap_fault primary fault: mm=ffff88024c9d8f40 address=3cea2dd000
pfn=44d68e
             cat-9122  [001]   191.143036: handle_mm_fault:
mm_anon_fault mm=ffff88024c8beb40 address=7fffbde99f94 pfn=24ce22
-------------------------------------------------------------------------

Signed-off-by: Larry Woodman <lwoodman@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>


The patch applies to ingo's latest tip tree:

--=-0npnriLYuljgwpaUBTnD
Content-Disposition: attachment; filename=0001-Merge-mm-tracepoints-into-upstream-tip-tree.patch
Content-Type: application/mbox; name=0001-Merge-mm-tracepoints-into-upstream-tip-tree.patch
Content-Transfer-Encoding: 7bit


--=-0npnriLYuljgwpaUBTnD--
