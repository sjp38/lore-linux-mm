Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD2856B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 08:56:58 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r9so73833676ywg.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:56:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t196si24064641qke.295.2016.08.10.05.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 05:56:57 -0700 (PDT)
Subject: Re: [PATCH v3] powerpc: Do not make the entire heap executable
References: <20160809190822.28856-1-dvlasenk@redhat.com>
 <CAGXu5j+arjRNmGVPeevMBsO6Mdpmw8Lq0GPvJvXNPJeQ8uCWkA@mail.gmail.com>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <3e1336d7-d0c1-beec-7526-af4eebc199fa@redhat.com>
Date: Wed, 10 Aug 2016 14:56:53 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+arjRNmGVPeevMBsO6Mdpmw8Lq0GPvJvXNPJeQ8uCWkA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oleg Nesterov <oleg@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/10/2016 12:43 AM, Kees Cook wrote:
>> -static int do_brk(unsigned long addr, unsigned long len)
>> +static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
>>  {
>>         struct mm_struct *mm = current->mm;
>>         struct vm_area_struct *vma, *prev;
>> -       unsigned long flags;
>>         struct rb_node **rb_link, *rb_parent;
>>         pgoff_t pgoff = addr >> PAGE_SHIFT;
>>         int error;
>> @@ -2666,7 +2665,7 @@ static int do_brk(unsigned long addr, unsigned long len)
>>         if (!len)
>>                 return 0;
>>
>> -       flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>> +       flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
>
> For sanity's sake, should a mask be applied here? i.e. to be extra
> careful about what flags can get passed in?

Maybe... I am leaving it to mm experts.

> Otherwise, this looks okay to me:
>
> Reviewed-by: Kees Cook <keescook@chromium.org>
>
> -Kees

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
