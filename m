Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAF96B0255
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 14:58:32 -0400 (EDT)
Received: by iodv82 with SMTP id v82so65820405iod.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:58:32 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id q6si18234593igr.43.2015.10.14.11.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 11:58:31 -0700 (PDT)
Date: Wed, 14 Oct 2015 13:58:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
In-Reply-To: <CA+55aFz+_Zh7O544QL3YCjTr1rfb-Q82wAyHTK8QMr+9X81h2g@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1510141356360.13663@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org> <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com> <20151014165729.GA12799@mtj.duckdns.org> <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
 <alpine.DEB.2.20.1510141253570.13238@east.gentwo.org> <CA+55aFz+_Zh7O544QL3YCjTr1rfb-Q82wAyHTK8QMr+9X81h2g@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, 14 Oct 2015, Linus Torvalds wrote:

> On Wed, Oct 14, 2015 at 10:57 AM, Christoph Lameter <cl@linux.com> wrote:
> >
> > Well yes the schedule_delayed_work_on() call is from another cpu and the
> > schedule_delayed_work() from the same. No confusion there.
>
> So "schedule_delayed_work()" does *not* guarantee that the work will
> run on the same CPU.

That is news to me. As far as I know: The only workqueue that is not
guaranteed to run on the same cpu is an unbound workqueue.

> If you want the scheduled work to happen on a particular CPU, then you
> should use "schedule_delayed_work_on()"  It shouldn't matter which CPU
> you call it from.

Ok then lets audit the kernel for this if that assumption is no longer
true.

> At least that's how I think the rules should be. Very simple, very
> clear: if you require a specific CPU, say so. Don't silently depend on
> "in practice, lots of times we tend to use the local cpu".

As far as I can remember this was guaranteed and not just practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
