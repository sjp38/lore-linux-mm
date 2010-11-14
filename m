Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 34BA58D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 02:14:06 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE7E353003310
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 16:14:03 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E6545DE51
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:14:03 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E043845DE4E
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:14:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDF081DB803C
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:14:02 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 747541DB803B
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 16:14:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/1][2nd resend] sys_unshare: remove the dead CLONE_THREAD/SIGHAND/VM code
In-Reply-To: <20101109171754.GB6971@redhat.com>
References: <20101109201742.BCA1.A69D9226@jp.fujitsu.com> <20101109171754.GB6971@redhat.com>
Message-Id: <20101114161354.BEDB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 16:14:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland McGrath <roland@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, JANAK DESAI <janak@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> On 11/09, KOSAKI Motohiro wrote:
> >
> > > -static void check_unshare_flags(unsigned long *flags_ptr)
> > > +static int check_unshare_flags(unsigned long unshare_flags)
> > >  {
> > > +	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
> > > +				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
> > > +				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
> > > +		return -EINVAL;
> >
> > Please put WARN_ON_ONCE() explicitly. That's good way to find hidden
> > user if exist and getting better bug report.
> 
> Perhaps... but this needs a separate change.
> 
> Please note that this check was simply moved from sys_unshare(), this
> patch shouldn't have any visible effect.
> 
> Personally, I think it would be even better if, say, unshare(CLONE_THREAD)
> returned -EINVAL unconditionally.

Ah, OK. you are right.



> > And, I've reveied this patch and I've found no fault. but I will not put
> > my ack because I think I haven't understand original intention perhaps.
> 
> Thanks!
> 
> IIRC, the main (only?) motivation for sys_unshare() was unshare_fs().
> Most probably unshare_thread/vm were added as placeholders.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
