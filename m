Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1C0926B00C1
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:19:39 -0500 (EST)
Message-ID: <50C0E1B6.5060602@fusionio.com>
Date: Thu, 6 Dec 2012 19:19:34 +0100
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com> <50BE5988.3050501@fusionio.com> <x498v9dpnwu.fsf@segfault.boston.devel.redhat.com> <50BE5C99.6070703@fusionio.com> <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com> <20121206180150.GQ19802@htj.dyndns.org>
In-Reply-To: <20121206180150.GQ19802@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo <mingo@redhat.com>

On 2012-12-06 19:01, Tejun Heo wrote:
> As for the original patch, I think it's a bit too much to expose to
> userland.  It's probably a good idea to bind the flusher to the local
> node but do we really need to expose an interface to let userland
> control the affinity directly?  Do we actually have a use case at
> hand?

We need to expose it. Once the binding is set from the kernel side on a
kernel thread, it can't be modified.

Binding either for performance reasons or for ensuring that we
explicitly don't run in some places is a very useful feature.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
