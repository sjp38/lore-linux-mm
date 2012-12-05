Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 1FB346B005D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 17:36:59 -0500 (EST)
Date: Wed, 5 Dec 2012 14:36:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Debugging: Keep track of page owners
Message-Id: <20121205143657.cad5baa5.akpm@linux-foundation.org>
In-Reply-To: <50BF88D0.9050209@linux.vnet.ibm.com>
References: <20121205011242.09C8667F@kernel.stglabs.ibm.com>
	<50BF61E0.1060307@codeaurora.org>
	<50BF88D0.9050209@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org

On Wed, 05 Dec 2012 09:48:00 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On 12/05/2012 07:01 AM, Laura Abbott wrote:\
> > Any reason you are using custom stack saving code instead of using the
> > save_stack_trace API? (include/linux/stacktrace.h) . This is implemented
> > on all architectures and takes care of special considerations for
> > architectures such as ARM.
> 
> This is actually an ancient patch that Andrew's been carrying around and
> updating periodically.  I didn't duck fast enough and got stuck updating
> it. :)

Yes, it's a sweet little patch and has saved our ass a few times.  It
would be nice if someone were to, umm, productize it and get it merged.

However, do see https://lkml.org/lkml/2009/4/1/137 where Ingo discusses
conversion to using the tracing infrastructure.

btw, the original patch was from the lost-lost and dearly missed
Alexander Nyberg <alexn@dsv.su.se>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
