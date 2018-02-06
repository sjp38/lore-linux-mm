Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C62456B0011
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 10:49:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so1594871pgt.17
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 07:49:23 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b24-v6si151356pls.617.2018.02.06.07.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 07:49:22 -0800 (PST)
Date: Tue, 6 Feb 2018 10:49:19 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180206104919.0bc1734d@gandalf.local.home>
In-Reply-To: <52fe3917-cf72-d512-8422-d53bacf40113@virtuozzo.com>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<151791238553.5994.4933976056810745303.stgit@localhost.localdomain>
	<20180206093451.0de5ceeb@gandalf.local.home>
	<52fe3917-cf72-d512-8422-d53bacf40113@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 Feb 2018 18:06:33 +0300
Kirill Tkhai <ktkhai@virtuozzo.com> wrote:


> There are kfree_rcu() and vfree_rcu() defined below, and they will give
> compilation error if someone tries to implement one more primitive with
> the same name.

Ah, I misread the patch. I was thinking you were simply replacing
kfree_rcu() with kvfree_rcu(), but now see the macros added below it.


> 
> We may add a comment, but I'm not sure it will be good if people will use
> unpaired brackets like:
> 
> 	obj = kmalloc(..)
> 	kvfree_rcu(obj,..)
> 
> after they read such a commentary that it works for both vmalloc and kmalloc.
> After this unpaired behavior distribute over the kernel, we won't be able
> to implement some debug on top of this defines (I'm not sure it will be really
> need in the future, but anyway).
> 
> Though, we may add a comment forcing use of paired bracket. Something like:
> 
> /**
>   * kvfree_rcu() - kvfree an object after a grace period.
>     This is a primitive for objects allocated via kvmalloc*() family primitives.
>     Do not use it to free kmalloc() and vmalloc() allocated objects, use kfree_rcu()
>     and vfree_rcu() wrappers instead.
> 
> How are you about this?

Never mind, I missed the adding of kfree_rcu() at the bottom, and was
thinking that we were just using kvfree_rcu() for everything.

That's what I get for looking at patches before my first cup of
coffee ;-)

If you want to add a comment, feel free, but taking a second look, I
don't feel it is necessary.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
