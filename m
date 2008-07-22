Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
References: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro>
	<1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro>
From: fche@redhat.com (Frank Ch. Eigler)
Date: Tue, 22 Jul 2008 17:28:16 -0400
In-Reply-To: <1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro> (eduard.munteanu@linux360.ro's message of "Tue, 22 Jul 2008 21:31:30 +0300")
Message-ID: <y0mvdyx7gnj.fsf@ton.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.co
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro> writes:

> kmemtrace provides tracing for slab allocator functions, such as kmalloc,
> kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
> to the userspace application in order to analyse allocation hotspots,
> internal fragmentation and so on, making it possible to see how well an
> allocator performs, as well as debug and profile kernel code.
> [...]

It may make sense to mention in addition that this version of
kmemtrace uses markers as the low-level hook mechanism, and this makes
the data generated directly accessible to other tracing tools such as
systemtap.  Thank you!


- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
