Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD7A6B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 16:30:12 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k129so52662147iof.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 13:30:12 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id h205si1338810oib.211.2016.05.10.13.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 13:30:11 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id v145so35478473oie.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 13:30:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160510182055.GA24868@redhat.com>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510182055.GA24868@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 10 May 2016 13:29:50 -0700
Message-ID: <CALCETrU4me1X7oTriLgFQpTqwaebMsT5sdYZzjC=_EERXNbqzA@mail.gmail.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Dmitry Safonov <0x7f454c46@gmail.com>, Borislav Petkov <bp@alien8.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Ruslan Kabatsayev <b7.10110111@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On May 10, 2016 11:21 AM, "Oleg Nesterov" <oleg@redhat.com> wrote:
>
> On 05/10, Andy Lutomirski wrote:
> >
> >  - xol_add_vma: This one is weird: uprobes really is doing something
> > behind the task's back, and the addresses need to be consistent with
> > the address width.  I'm not quite sure what to do here.
>
> It can use mm->task_size instead, plus this is just a hint. And perhaps
> mm->task_size should have more users, say get_unmapped_area...

Ick.  I hadn't noticed mm->task_size.  We have a *lot* of different
indicators of task size.  mm->task_size appears to have basically no
useful uses except maybe for ppc.

On x86, bitness can change without telling the kernel, and tasks
running in 64-bit mode can do 32-bit syscalls.

So maybe I should add mm->task_size to my list of things that would be
nice to remove.  Or maybe I'm just tilting at windmills.

>
> Not sure we should really get rid of dynamic TASK_SIZE completely, but
> personally I agree it looks a bit ugly.
>
> Oleg.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
