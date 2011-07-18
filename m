Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C59A66B00E7
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 11:05:20 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6IEwxuG030106
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 00:58:59 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6IF4now860372
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 01:04:49 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6IF5G7N016191
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 01:05:16 +1000
Date: Tue, 19 Jul 2011 00:35:09 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RESEND] Cross Memory Attach v3
Message-ID: <20110719003509.77b5ed66@lilo>
In-Reply-To: <20110715153743.a0b3efc7.akpm@linux-foundation.org>
References: <20110708180607.3f11d324@lilo>
 <20110715153743.a0b3efc7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Fri, 15 Jul 2011 15:37:43 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 8 Jul 2011 18:06:07 +0930
> Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> 
> > +static ssize_t process_vm_rw(pid_t pid, const struct iovec *lvec,
> > +			     unsigned long liovcnt,
> > +			     const struct iovec *rvec,
> > +			     unsigned long riovcnt,
> > +			     unsigned long flags, int vm_write)
> > +{
> >
> > ...
> >
> > +	if (!mm || (task->flags & PF_KTHREAD)) {
> 
> Can a PF_KTHREAD thread have a non-zero ->mm?
> > +		task_unlock(task);
> > +		rc = -EINVAL;
> > +		goto put_task_struct;
> > +	}

According to get_task_mm it can:

/**
 * get_task_mm - acquire a reference to the task's mm
 *
 * Returns %NULL if the task has no mm.  Checks PF_KTHREAD (meaning
 * this kernel workthread has transiently adopted a user mm with use_mm,
 * to do its AIO) is not set and if so returns a reference to it, after
 * bumping up the use count.  User must release the mm via mmput()
 * after use.  Typically used by /proc and ptrace.
 */

> anyway, grumble.
> 
> Please resend, cc'ing linux-kernel.

Am doing the CC resends in a separate email...

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
