Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 150F76B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:59:40 -0400 (EDT)
Message-ID: <504A7C5C.1000706@jp.fujitsu.com>
Date: Fri, 07 Sep 2012 18:59:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mempolicy: fix a race in shared_policy_replace()
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1345480594-27032-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, davej@redhat.com, cl@linux.com, ben@decadent.org.uk, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

First off, thank you very much for reworking this for me. I haven't got a chance
to get a test machine for this.

> shared_policy_replace() use of sp_alloc() is unsafe. 1) sp_node cannot
> be dereferenced if sp->lock is not held and 2) another thread can modify
> sp_node between spin_unlock for allocating a new sp node and next spin_lock.
> The bug was introduced before 2.6.12-rc2.
> 
> Kosaki's original patch for this problem was to allocate an sp node and policy
> within shared_policy_replace and initialise it when the lock is reacquired. I
> was not keen on this approach because it partially duplicates sp_alloc(). As
> the paths were sp->lock is taken are not that performance critical this
> patch converts sp->lock to sp->mutex so it can sleep when calling sp_alloc().

Looks make sense.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
