Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 702746B00A2
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 21:55:49 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: tracehooks changes && 2.6.32 -mm merge plans
In-Reply-To: Oleg Nesterov's message of  Thursday, 17 September 2009 22:46:56 +0200 <20090917204656.GC29346@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
	<20090917204656.GC29346@redhat.com>
Message-Id: <20090917215635.73CE89A5@magilla.sf.frob.com>
Date: Thu, 17 Sep 2009 14:56:35 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Frank Ch. Eigler" <fche@redhat.com>, Christoph Hellwig <hch@lst.de>, utrace-devel@redhat.com
List-ID: <linux-mm.kvack.org>

> On 09/15, Andrew Morton wrote:
> >
> > #signals-tracehook_notify_jctl-change.patch: needs changelog folding too
> > signals-tracehook_notify_jctl-change.patch
> > signals-tracehook_notify_jctl-change-do_signal_stop-do-not-call-tracehook_notify_jctl-in-task_stopped-state.patch
> > #signals-introduce-tracehook_finish_jctl-helper.patch: fold into signals-tracehook_notify_jctl-change.patch
> > signals-introduce-tracehook_finish_jctl-helper.patch
> 
> I think these make sense anyway,

Agreed.

> > utrace-core.patch
> >
> >   utrace.  What's happening with this?
> 
> (since Roland didn't reply yet)
> 
> I guess this patch should be updated.

We do have a newer version now with various fixes and clean-ups.
But the current version does not play nice with ptrace (does not
even exclude ptrace any more).  Without at least the ptrace
exclusion, using both utrace modules and ptrace might lead to a
confused kernel or BUG_ON hits.

Past feedback tells us that we need some in-tree users of the
utrace API to get merged too.  Frank was working on such a thing,
and the IBM folks may have another such thing, but I don't know
the present status of those modules.

Oleg is working feverishly on revamping ptrace using utrace.
Other past feedback has suggested this is what people want to see
to justify utrace going in.  That ptrace work is still a bit away
from being ready even for -mm submission.  We're pretty sure that
we will do some more changes in the utrace core to make that work
well, so utrace merged first would be sure to get more changes
later (probably including some API differences).


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
