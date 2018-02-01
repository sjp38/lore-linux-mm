Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25D996B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 16:11:18 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id e71so11666500vkd.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 13:11:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h38sor206003uah.88.2018.02.01.13.11.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 13:11:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com> <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
 <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 2 Feb 2018 08:11:15 +1100
Message-ID: <CAGXu5jKKeJL13dcaY=fDJ8AiOXDP5MhQTqDYDOt3a374CFA1HQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Christopher Lameter <cl@linux.com>, jglisse@redhat.com, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com

On Thu, Feb 1, 2018 at 11:42 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> On 01/02/18 02:00, Christopher Lameter wrote:
>> Would it not be better to use compound page allocations here?
>> page_head(whatever) gets you the head page where you can store all sorts
>> of information about the chunk of memory.
>
> Can you please point me to this function/macro? I don't seem to be able
> to find it, at least not in 4.15

IIUC, he means PageHead(), which is also hard to grep for, since it is
a constructed name, via Page##uname in include/linux/page-flags.h:

__PAGEFLAG(Head, head, PF_ANY) CLEARPAGEFLAG(Head, head, PF_ANY)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
