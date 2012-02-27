Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DDD636B00ED
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 18:01:24 -0500 (EST)
Date: Mon, 27 Feb 2012 16:39:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <87d390janv.fsf@xmission.com>
Message-ID: <alpine.DEB.2.00.1202271636230.6435@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home> <alpine.DEB.2.00.1202241105280.3726@router.home> <4F47C800.4090903@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202241131400.3726@router.home> <87sjhzun47.fsf@xmission.com> <alpine.DEB.2.00.1202271238450.32410@router.home> <87d390janv.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 27 Feb 2012, Eric W. Biederman wrote:

> The problem that I see is that we may race with a suid exec in which
> case the permissions checks might pass for the pre-exec state and then
> we get the post exec mm that we don't actually have permissions for,
> but we manipulate it anyway.

So what? Page migration does not change the behavior of the code. It only
changes the latencies seen. The hacker can mess up the code so that the
suid exec runs slower?

> So we really need to do something silly like get task and
> task->self_exec_id.  Then perform the permission checks and get the mm.
> Then if just before we perform the operation task->self_exec_id is
> different restart the system call, or fail with something like -EAGAIN.

I am still not convinced as to why we would do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
