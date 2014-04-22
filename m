Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id DE1E36B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:01:45 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so4880529ier.13
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:01:45 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id qg3si10910022igb.35.2014.04.22.00.01.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 00:01:45 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so4905999iec.9
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:01:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA@mail.gmail.com>
References: <1398144620-9630-1-git-send-email-nasa4836@gmail.com> <CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA@mail.gmail.com>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 15:01:04 +0800
Message-ID: <CAHz2CGXsvdtVdwZfyFAwtRHJ_vkeJZXtLv4fTGTYEeEwN7H6Qw@mail.gmail.com>
Subject: Re: [PATCH] hugetlb_cgroup: explicitly init the early_init field
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, containers@lists.linux-foundation.org, Cgroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi, hillf,

On Tue, Apr 22, 2014 at 2:47 PM, Hillf Danton <dhillf@gmail.com> wrote:
> But other fields still missed, if any. Fair?

yep, it is not fair.

Sure for this global variable struct, if not initailized, its all
fields will be initialized
to 0 or null(depending on its type).  The point here is no to deprive
the rights of
compiler/linker of doing this initialization, it is mainly for
documentation reason.
Actually this field's value would affect how ->css_alloc should implemented.

Concretely, if early_init is nonzero, then ->css_alloc *must not* call kzalloc,
because in cgroup implementation, ->css_alloc will be called earlier before
mm_init().

I don't think that the value of one field(early_init) has a so subtle
restrition on the
another field(css_alloc) is a good thing, but since it is there,
docment it should
be needed.


Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
