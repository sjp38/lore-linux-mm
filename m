Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 325446B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 10:12:27 -0400 (EDT)
Date: Wed, 24 Aug 2011 09:12:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/13] dcache: convert dentry_stat.nr_unused to per-cpu
 counters
In-Reply-To: <1314089786-20535-3-git-send-email-david@fromorbit.com>
Message-ID: <alpine.DEB.2.00.1108240910440.24118@router.home>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com> <1314089786-20535-3-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On Tue, 23 Aug 2011, Dave Chinner wrote:

> Before we split up the dcache_lru_lock, the unused dentry counter
> needs to be made independent of the global dcache_lru_lock. Convert
> it to per-cpu counters to do this.

I hope there is nothing depending on the counter being accurate.

Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
