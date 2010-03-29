Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B2AA6B01C2
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 07:48:07 -0400 (EDT)
Date: Mon, 29 Mar 2010 13:46:30 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100329114630.GA19277@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <20100329113113.GA11838@desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100329113113.GA11838@desktop>
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/29, anfei wrote:
>
> On Sun, Mar 28, 2010 at 06:28:21PM +0200, Oleg Nesterov wrote:
> > On 03/28, anfei wrote:
> > >
> > > Assume thread A and B are in the same group.  If A runs into the oom,
> > > and selects B as the victim, B won't exit because at least in exit_mm(),
> > > it can not get the mm->mmap_sem semaphore which A has already got.
> >
> > I see. But still I can't understand. To me, the problem is not that
> > B can't exit, the problem is that A doesn't know it should exit. All
>
> If B can exit, its memory will be freed,

Which memory? I thought, we are talking about the memory used by ->mm ?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
