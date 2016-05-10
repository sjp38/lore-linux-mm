Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79ACE6B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 14:21:04 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id e126so41287880vkb.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 11:21:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d77si2326962qhd.7.2016.05.10.11.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 11:21:03 -0700 (PDT)
Date: Tue, 10 May 2016 20:20:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Message-ID: <20160510182055.GA24868@redhat.com>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>

On 05/10, Andy Lutomirski wrote:
>
>  - xol_add_vma: This one is weird: uprobes really is doing something
> behind the task's back, and the addresses need to be consistent with
> the address width.  I'm not quite sure what to do here.

It can use mm->task_size instead, plus this is just a hint. And perhaps
mm->task_size should have more users, say get_unmapped_area...

Not sure we should really get rid of dynamic TASK_SIZE completely, but
personally I agree it looks a bit ugly.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
