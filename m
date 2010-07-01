Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C62636006F7
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:38:56 -0400 (EDT)
Received: by pxi17 with SMTP id 17so934117pxi.14
        for <linux-mm@kvack.org>; Thu, 01 Jul 2010 06:38:54 -0700 (PDT)
Date: Thu, 1 Jul 2010 22:38:46 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 02/11] oom: oom_kill_process() doesn't select kthread
 child
Message-ID: <20100701133846.GA16383@barrios-desktop>
References: <20100630182715.AA4B.A69D9226@jp.fujitsu.com>
 <20100630135503.GA15644@barrios-desktop>
 <20100701085011.DA13.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100701085011.DA13.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 09:07:02AM +0900, KOSAKI Motohiro wrote:
> > On Wed, Jun 30, 2010 at 06:27:52PM +0900, KOSAKI Motohiro wrote:
> > > Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> > > doesn't. It mean oom_kill_process() may choose wrong task, especially,
> > > when the child are using use_mm().
> > 
> > Is it possible child is kthread even though parent isn't kthread?
> 
> Usually unhappen. but crappy driver can do any strange thing freely.
> As I said, oom code should have conservative assumption as far as possible.

Okay. You change the check with oom_unkillable_task at last. 
The oom_unkillable_task is generic function so that the kthread check in
oom_kill_process is tivial, I think. 

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


> 
> 
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
