Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 16B168D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 03:18:08 -0500 (EST)
Date: Fri, 21 Jan 2011 00:18:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH] mm: Use spin_lock_irqsave in
 __set_page_dirty_nobuffers
Message-Id: <20110121001804.413b3f6d.akpm@linux-foundation.org>
In-Reply-To: <1294726534-16438-1-git-send-email-andy.grover@oracle.com>
References: <1294726534-16438-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andy Grover <andy.grover@oracle.com>
Cc: linux-mm@kvack.org, rds-devel@oss.oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jan 2011 22:15:34 -0800 Andy Grover <andy.grover@oracle.com> wrote:

> RDS is calling set_page_dirty from interrupt context,

yikes.  Whatever possessed you to try that?

> @@ -1155,11 +1155,12 @@ int __set_page_dirty_nobuffers(struct page *page)

__set_page_dirty_buffers(): bug, takes mapping->private_lock in irq context
                            bug, __set_page_dirty() reenables IRQs
ceph_set_page_dirty():      more bugs than I care to enumerate
nilfs_set_file_dirty():	    bug, takes sbi->s_inode_lock in IRQ context

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
