Date: Tue, 06 May 2008 15:43:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
In-Reply-To: <481FFAAB.3030008@linux.vnet.ibm.com>
References: <20080506151510.AC66.KOSAKI.MOTOHIRO@jp.fujitsu.com> <481FFAAB.3030008@linux.vnet.ibm.com>
Message-Id: <20080506153943.AC69.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> >  #ifdef CONFIG_MM_OWNER
> > -       struct task_struct *owner;      /* The thread group leader that */
> > -                                       /* owns the mm_struct.          */
> > +       struct task_struct *owner;      /* point to one of task that owns the mm_struct. */
> >  #endif
> > 
> >  #ifdef CONFIG_PROC_FS
> 
> How about just, the task that owns the mm_struct? One of, implies multiple owners.

Ah, below is better?

/* point to any one of task that related the mm_struct. */


my intention is only remove "thread group leader" word.
other things, I obey your favor. 

Cheers!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
