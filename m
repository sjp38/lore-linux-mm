Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 85A246B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 14:03:40 -0400 (EDT)
Received: by ioii196 with SMTP id i196so63874290ioi.3
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:03:40 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 76si8324811ioi.23.2015.10.14.11.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 11:03:39 -0700 (PDT)
Date: Wed, 14 Oct 2015 13:03:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
In-Reply-To: <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1510141301340.13301@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org> <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, 14 Oct 2015, Linus Torvalds wrote:

> On Tue, Oct 13, 2015 at 2:49 PM, Tejun Heo <tj@kernel.org> wrote:
> >
> > Single patch to fix delayed work being queued on the wrong CPU.  This
> > has been broken forever (v2.6.31+) but obviously doesn't trigger in
> > most configurations.
>
> So why is this a bugfix? If cpu == WORK_CPU_UNBOUND, then things
> _shouldn't_ care which cpu it gets run on.

UNBOUND means not fixed to a processor. The system should have
freedom to schedule unbound work requests anywhere it wants. This is
something we also want for the NOHZ work in order to move things like
these workqueue items to processors that are not supposed to be low
latency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
