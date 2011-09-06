Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 89D266B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 08:14:12 -0400 (EDT)
Subject: Re: [PATCH 06/18] writeback: IO-less balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 06 Sep 2011 14:13:53 +0200
In-Reply-To: <20110904020915.383842632@intel.com>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.383842632@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315311233.12533.3.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> -static inline void task_dirties_fraction(struct task_struct *tsk,
> -               long *numerator, long *denominator)
> -{
> -       prop_fraction_single(&vm_dirties, &tsk->dirties,
> -                               numerator, denominator);
> -}=20

it looks like this patch removes all users of tsk->dirties, but doesn't
in fact remove the data member from task_struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
