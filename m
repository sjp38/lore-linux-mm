Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 984E56B01AD
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 08:09:11 -0400 (EDT)
Date: Mon, 29 Mar 2010 20:09:04 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100329120904.GB11838@desktop>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com>
 <20100326150805.f5853d1c.akpm@linux-foundation.org>
 <20100326223356.GA20833@redhat.com>
 <20100328145528.GA14622@desktop>
 <20100328162821.GA16765@redhat.com>
 <20100329113113.GA11838@desktop>
 <20100329114630.GA19277@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100329114630.GA19277@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 29, 2010 at 01:46:30PM +0200, Oleg Nesterov wrote:
> On 03/29, anfei wrote:
> >
> > On Sun, Mar 28, 2010 at 06:28:21PM +0200, Oleg Nesterov wrote:
> > > On 03/28, anfei wrote:
> > > >
> > > > Assume thread A and B are in the same group.  If A runs into the oom,
> > > > and selects B as the victim, B won't exit because at least in exit_mm(),
> > > > it can not get the mm->mmap_sem semaphore which A has already got.
> > >
> > > I see. But still I can't understand. To me, the problem is not that
> > > B can't exit, the problem is that A doesn't know it should exit. All
> >
> > If B can exit, its memory will be freed,
> 
> Which memory? I thought, we are talking about the memory used by ->mm ?
> 
There is also a little kernel struct related to the task can be freed,
but I think you are correct, the memory used by ->mm takes more effect,
and it won't be freed even B exits. So I agree you on:
"
the problem is not that B can't exit, the problem is that A doesn't know
it should exit. All threads should exit and free ->mm. Even if B could
exit, this is not enough. And, to some extent, it doesn't matter if it
holds mmap_sem or not.
"

Thanks,
Anfei.

> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
