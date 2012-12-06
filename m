Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D84708D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:08:23 -0500 (EST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher threads
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
	<50BE5988.3050501@fusionio.com>
	<x498v9dpnwu.fsf@segfault.boston.devel.redhat.com>
	<50BE5C99.6070703@fusionio.com>
	<x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
	<20121206180150.GQ19802@htj.dyndns.org>
Date: Thu, 06 Dec 2012 13:08:18 -0500
In-Reply-To: <20121206180150.GQ19802@htj.dyndns.org> (Tejun Heo's message of
	"Thu, 6 Dec 2012 10:01:50 -0800")
Message-ID: <x494njzxdd9.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <jaxboe@fusionio.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo <mingo@redhat.com>

Tejun Heo <tj@kernel.org> writes:

> Hmmm... cpu binding usually is done by kthread_bind() or explicit
> set_cpus_allowed_ptr() by the kthread itself.  The node part of the
> API was added later because there was no way to control where the
> stack is allocated and we often ended up with kthreads which are bound
> to a CPU with stack on a remote node.
>
> I don't know.  @node usually controls memory allocation and it could
> be surprising for it to control cpu binding, especially because most
> kthreads which are bound to CPU[s] require explicit affinity
> management as CPUs go up and down.  I don't know.  Maybe I'm just too
> used to the existing interface.

OK, I can understand this line of reasoning.

> As for the original patch, I think it's a bit too much to expose to
> userland.  It's probably a good idea to bind the flusher to the local
> node but do we really need to expose an interface to let userland
> control the affinity directly?  Do we actually have a use case at
> hand?

Yeah, folks pinning realtime processes to a particular cpu don't want
the flusher threads interfering with their latency.  I don't have any
performance numbers on hand to convince you of the benefit, though.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
