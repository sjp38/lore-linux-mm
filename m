Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8E706B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 03:14:07 -0400 (EDT)
Subject: Re: [patch 2/2] procfs: provide stack information for threads V0.8
From: Stefani Seibold <stefani@seibold.net>
In-Reply-To: <20090615150121.ce04ba08.akpm@linux-foundation.org>
References: <1238511505.364.61.camel@matrix>
	 <20090401193135.GA12316@elte.hu> <1244618442.17616.5.camel@wall-e>
	 <20090615150121.ce04ba08.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 16 Jun 2009 09:14:11 +0200
Message-Id: <1245136451.17989.12.camel@wall-e>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Am Montag, den 15.06.2009, 15:01 -0700 schrieb Andrew Morton:
> > ...
> >
> > --- linux-2.6.30.orig/include/linux/sched.h	2009-06-04 09:29:47.000000000 +0200
> > +++ linux-2.6.30/include/linux/sched.h	2009-06-04 09:32:35.000000000 +0200
> > @@ -1429,6 +1429,7 @@
> >  	/* state flags for use by tracers */
> >  	unsigned long trace;
> >  #endif
> > +	unsigned long stack_start;
> >  };
> >  
> 
> A `stack_start' in the task_struct.  This is a bit confusing - we
> already have a `void *stack' in there.  Perhaps this should be named
> user_stack_start or something?
> 
> 
IMHO i think the void *stack is also a to general name, it should be
name kernel_stack or thread_info.

In real we have two stack, so the name user_stack and kernel_stack would
be my favor.

I have examined the source and and task_struct void *stack would be used
in about 10 files.
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
