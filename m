Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2296B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:15:24 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so4636906pbc.13
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:15:24 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id vv4si9220121pbc.21.2014.04.22.00.15.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 00:15:23 -0700 (PDT)
Message-ID: <535616D9.8060702@huawei.com>
Date: Tue, 22 Apr 2014 15:14:33 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb_cgroup: explicitly init the early_init field
References: <1398144620-9630-1-git-send-email-nasa4836@gmail.com> <CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA@mail.gmail.com> <CAHz2CGXsvdtVdwZfyFAwtRHJ_vkeJZXtLv4fTGTYEeEwN7H6Qw@mail.gmail.com>
In-Reply-To: <CAHz2CGXsvdtVdwZfyFAwtRHJ_vkeJZXtLv4fTGTYEeEwN7H6Qw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, Tejun Heo <tj@kernel.org>, containers@lists.linux-foundation.org, Cgroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/4/22 15:01, Jianyu Zhan wrote:
> Hi, hillf,
> 
> On Tue, Apr 22, 2014 at 2:47 PM, Hillf Danton <dhillf@gmail.com> wrote:
>> But other fields still missed, if any. Fair?
> 
> yep, it is not fair.
> 
> Sure for this global variable struct, if not initailized, its all
> fields will be initialized
> to 0 or null(depending on its type).  The point here is no to deprive
> the rights of
> compiler/linker of doing this initialization, it is mainly for
> documentation reason.
> Actually this field's value would affect how ->css_alloc should implemented.
> 
> Concretely, if early_init is nonzero, then ->css_alloc *must not* call kzalloc,
> because in cgroup implementation, ->css_alloc will be called earlier before
> mm_init().
> 
> I don't think that the value of one field(early_init) has a so subtle
> restrition on the
> another field(css_alloc) is a good thing, but since it is there,
> docment it should
> be needed.
> 

I don't see how things can be improved by initializing it to 0 explicitly,
if anything needs to be improved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
