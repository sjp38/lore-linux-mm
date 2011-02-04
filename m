Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC0D38D0041
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:15:58 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLVy-0005C9-Uo
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:15:55 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PlLVx-0001mU-KD
	for linux-mm@kvack.org; Fri, 04 Feb 2011 13:15:53 +0000
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1296783534-11585-4-git-send-email-jack@suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
	 <1296783534-11585-4-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 14:09:15 +0100
Message-ID: <1296824955.26581.645.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> +struct balance_waiter {
> +       struct list_head bw_list;
> +       unsigned long bw_to_write;      /* Number of pages to wait for to
> +                                          get written */

That names somehow rubs me the wrong way.. the name suggests we need to
do the writing, whereas we only wait for them to be written.

> +       struct task_struct *bw_task;    /* Task waiting for IO */
> +}; 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
