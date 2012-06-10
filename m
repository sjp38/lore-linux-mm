Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id C47BB6B005C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:48:00 -0400 (EDT)
Date: Sun, 10 Jun 2012 15:47:52 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] page-writeback.c: fix update bandwidth time judgment
 error
Message-ID: <20120610074752.GA11506@localhost>
References: <1339302005-366-1-git-send-email-liwp.linux@gmail.com>
 <20120610043641.GA10355@localhost>
 <20120610045300.GA29336@kernel>
 <20120610072414.GA11283@localhost>
 <20120610074115.GA2400@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120610074115.GA2400@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp@linux.vnet.ibm.com>

> static void global_update_bandwidth(unsigned long thresh,
> 				    unsigned long dirty,
> 					unsigned long now)
> {
> 	static DEFINE_SPINLOCK(dirty_lock);
>     static unsigned long update_time;
> 
>     /*
> 	 * check locklessly first to optimize away locking for the most time
>      */
> 	if (time_before(now, update_time + BANDWIDTH_INTERVAL))
> 		return;
>     
> 	spin_lock(&dirty_lock);
>     if (time_after_eq(now, update_time + BANDWIDTH_INTERVAL)) {
> 		update_dirty_limit(thresh, dirty);
> 		update_time = now;
> 	}
> 	spin_unlock(&dirty_lock);
> }
> 
> So time_after_eq in global_update_bandwidth function should also change
> to time_after, or just ignore this disunion?

Let's just ignore them. You are very careful and I like it.
Please move on and keep up the good work!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
