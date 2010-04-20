Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C62A16B01F3
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 10:00:17 -0400 (EDT)
Received: by pvg11 with SMTP id 11so3730297pvg.14
        for <linux-mm@kvack.org>; Tue, 20 Apr 2010 07:00:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100420134322.GM20640@cmpxchg.org>
References: <y2t448a67a1004200538l45d46338vcd77b63a0e53d54e@mail.gmail.com>
	 <20100420134322.GM20640@cmpxchg.org>
Date: Tue, 20 Apr 2010 19:30:15 +0530
Message-ID: <s2i448a67a1004200700n4242a936tbaf4df2b4c710ab2@mail.gmail.com>
Subject: Re: accessing stack of non-current task
From: Uma shankar <shankar.vk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 7:13 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Apr 20, 2010 at 06:08:14PM +0530, Uma shankar wrote:
>> Hi,
>>
>> Is it possible for the kernel to access the user-stack data of a
>> task different from "current" ? ( This is needed for stack-dump as
>> well as backtrace. )
>
> Yes, have a look at __get_user_pages() in mm/memory.c.
>

Yes,  I understand this.

But  have a look  at  "void show_stack(struct task_struct *tsk,
unsigned long *sp)  "  in traps.c (  arch specific  ).

Is there a implicit assumption that  "tsk"  and "current"  are threads
sharing same  "mm_strct"  ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
