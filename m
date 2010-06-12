Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E05896B01AC
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 21:50:36 -0400 (EDT)
Received: by vws8 with SMTP id 8so2282455vws.14
        for <linux-mm@kvack.org>; Fri, 11 Jun 2010 18:50:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1276250772.12258.57.camel@e102109-lin.cambridge.arm.com>
References: <AANLkTiktcGrj-tcMspzR3sXplKk-PFB7M4q7rb-WiwYP@mail.gmail.com>
	<1276250772.12258.57.camel@e102109-lin.cambridge.arm.com>
Date: Sat, 12 Jun 2010 09:50:34 +0800
Message-ID: <AANLkTikc3NAxOXANiFLJ9SqhdHs_11QsnX-JlwF95Alz@mail.gmail.com>
Subject: Re: [PATCH -mm] only drop root anon_vma if not self
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 6:06 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Fri, 2010-06-11 at 10:48 +0100, Dave Young wrote:
>> I got an oops when shutdown kvm guest with rik's patch applied, but
>> without your bootmem patch, is it kmemleak problem?
>
> It could be, though I've never got it before.
>
> Can you run this on your vmlinux file?
>
> addr2line -i -f -e vmlinux c10c5c88

The vmlinux is lost, I rebuid it with same config

bash-3.1$ addr2line -i -f -e vmlinux 0xc10c5c88
put_object
/home/dave/mm/linux-2.6.35-rc1/mm/kmemleak.c:45

>
> Thanks.
>
> --
> Catalin
>
>



-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
