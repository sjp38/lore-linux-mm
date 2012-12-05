Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 64F0D6B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 12:48:12 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 5 Dec 2012 12:48:10 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DB1F0C9001C
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 12:48:06 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB5Hm692309370
	for <linux-mm@kvack.org>; Wed, 5 Dec 2012 12:48:06 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB5Hm6ux008358
	for <linux-mm@kvack.org>; Wed, 5 Dec 2012 12:48:06 -0500
Message-ID: <50BF88D0.9050209@linux.vnet.ibm.com>
Date: Wed, 05 Dec 2012 09:48:00 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Debugging: Keep track of page owners
References: <20121205011242.09C8667F@kernel.stglabs.ibm.com> <50BF61E0.1060307@codeaurora.org>
In-Reply-To: <50BF61E0.1060307@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: akpm@osdl.org, linux-mm@kvack.org

On 12/05/2012 07:01 AM, Laura Abbott wrote:\
> Any reason you are using custom stack saving code instead of using the
> save_stack_trace API? (include/linux/stacktrace.h) . This is implemented
> on all architectures and takes care of special considerations for
> architectures such as ARM.

This is actually an ancient patch that Andrew's been carrying around and
updating periodically.  I didn't duck fast enough and got stuck updating
it. :)

> MIGRATE_CMA pages (with CONFIG_CMA) will always have pagetype != mtype
> so CMA pages will always show up here even though they are considered
> movable pages. That's probably not what you want here.

What do you think the the right way to handle it is?  Should we just
check explicitly for CMA pages and punt on them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
