Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 977C56B0026
	for <linux-mm@kvack.org>; Mon, 16 May 2011 21:54:15 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4H1Va26025347
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:31:36 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4H1lqk4152800
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:47:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GJlOhr013914
	for <linux-mm@kvack.org>; Mon, 16 May 2011 13:47:25 -0600
Subject: Re: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect
 task->comm access
From: John Stultz <john.stultz@linaro.org>
In-Reply-To: <4DD19EB5.7060900@gmail.com>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
	 <1305580757-13175-2-git-send-email-john.stultz@linaro.org>
	 <4DD19EB5.7060900@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 18:47:47 -0700
Message-ID: <1305596867.2915.109.camel@work-vm>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-17 at 00:01 +0200, Jiri Slaby wrote:
> On 05/16/2011 11:19 PM, John Stultz wrote:
> > diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> > index caa151f..b69d94b 100644
> > --- a/include/linux/init_task.h
> > +++ b/include/linux/init_task.h
> > @@ -161,6 +161,7 @@ extern struct cred init_cred;
> >  	.group_leader	= &tsk,						\
> >  	RCU_INIT_POINTER(.real_cred, &init_cred),			\
> >  	RCU_INIT_POINTER(.cred, &init_cred),				\
> > +	.comm_lock	= __SPIN_LOCK_UNLOCKED(tsk.comm_lock),		\
> 
> Hmm, you should also init the spinlock somewhere in copy_process.
> Otherwise when a process is forked in the middle of [gs]et_task_comm
> called on it on another cpu, you have two locked locks and only the
> parent's will be unlocked, right?

Ah, yep. Fixed for the next version.

thanks!
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
