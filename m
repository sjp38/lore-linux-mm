Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D92446B00C6
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:22:45 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4891697pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 10:22:45 -0800 (PST)
Date: Thu, 6 Dec 2012 10:22:39 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121206182239.GS19802@htj.dyndns.org>
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
 <50BE5988.3050501@fusionio.com>
 <x498v9dpnwu.fsf@segfault.boston.devel.redhat.com>
 <50BE5C99.6070703@fusionio.com>
 <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
 <20121206180150.GQ19802@htj.dyndns.org>
 <50C0E1B6.5060602@fusionio.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C0E1B6.5060602@fusionio.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo <mingo@redhat.com>

Hello, Jens.

On Thu, Dec 06, 2012 at 07:19:34PM +0100, Jens Axboe wrote:
> We need to expose it. Once the binding is set from the kernel side on a
> kernel thread, it can't be modified.

That's only if kthread_bind() is used.  Caling set_cpus_allowed_ptr()
doesn't set PF_THREAD_BOUND and userland can adjust affinity like any
other tasks.

> Binding either for performance reasons or for ensuring that we
> explicitly don't run in some places is a very useful feature.

Sure, but I think this is too specific.  Something more generic would
be much better.  It can be as simple as generating a uevent.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
