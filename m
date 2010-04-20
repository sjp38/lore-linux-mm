Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D457A6B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 13:16:41 -0400 (EDT)
Date: Tue, 20 Apr 2010 19:16:37 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: accessing stack of non-current task
Message-ID: <20100420171637.GN20640@cmpxchg.org>
References: <y2t448a67a1004200538l45d46338vcd77b63a0e53d54e@mail.gmail.com> <20100420134322.GM20640@cmpxchg.org> <s2i448a67a1004200700n4242a936tbaf4df2b4c710ab2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <s2i448a67a1004200700n4242a936tbaf4df2b4c710ab2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Uma shankar <shankar.vk@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 07:30:15PM +0530, Uma shankar wrote:
> On Tue, Apr 20, 2010 at 7:13 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Apr 20, 2010 at 06:08:14PM +0530, Uma shankar wrote:
> >> Hi,
> >>
> >> Is it possible for the kernel to access the user-stack data of a
> >> task different from "current" ? ( This is needed for stack-dump as
> >> well as backtrace. )
> >
> > Yes, have a look at __get_user_pages() in mm/memory.c.
> >
> 
> Yes,  I understand this.
> 
> But  have a look  at  "void show_stack(struct task_struct *tsk,
> unsigned long *sp)  "  in traps.c (  arch specific  ).
> 
> Is there a implicit assumption that  "tsk"  and "current"  are threads
> sharing same  "mm_strct"  ?

No, this is dumping the _kernel stack_ of a process, not the user stack.

The mm_struct does not matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
