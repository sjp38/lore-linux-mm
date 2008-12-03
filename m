Subject: Re: [PATCH][V7]make get_user_pages interruptible
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20081203161834.1D4A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
	 <20081203161834.1D4A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Wed, 03 Dec 2008 10:21:48 +0200
Message-Id: <1228292508.22472.14.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-03 at 16:19 +0900, KOSAKI Motohiro wrote:
> > From: Ying Han <yinghan@google.com>
> > 
> > make get_user_pages interruptible
> > The initial implementation of checking TIF_MEMDIE covers the cases of OOM
> > killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
> > return immediately. This patch includes:
> > 
> > 1. add the case that the SIGKILL is sent by user processes. The process can
> > try to get_user_pages() unlimited memory even if a user process has sent a
> > SIGKILL to it(maybe a monitor find the process exceed its memory limit and
> > try to kill it). In the old implementation, the SIGKILL won't be handled
> > until the get_user_pages() returns.
> > 
> > 2. change the return value to be ERESTARTSYS. It makes no sense to return
> > ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
> > Considering the general convention for a system call interrupted by a
> > signal is ERESTARTNOSYS, so the current return value is consistant to that.
> > 
> > Signed-off-by:	Paul Menage <menage@google.com>
> > Signed-off-by:	Ying Han <yinghan@google.com>
> 
> looks good to me.
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Looks good to me too.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
