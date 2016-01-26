Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7AD6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:25:49 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id e32so149920169qgf.3
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:25:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p63si519977qki.107.2016.01.26.12.25.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:25:48 -0800 (PST)
Subject: Re: [RFC][PATCH 1/3] mm/debug-pagealloc.c: Split out page poisoning
 from debug page_alloc
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
 <1453740953-18109-2-git-send-email-labbott@fedoraproject.org>
 <CAHz2CGXuUHYHX7KhxGjYtWrKOoxK=2Rz2N-Q0CBR9UWtrYi2Jw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56A7D648.8020806@redhat.com>
Date: Tue, 26 Jan 2016 12:25:44 -0800
MIME-Version: 1.0
In-Reply-To: <CAHz2CGXuUHYHX7KhxGjYtWrKOoxK=2Rz2N-Q0CBR9UWtrYi2Jw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On 01/25/2016 10:26 PM, Jianyu Zhan wrote:
> On Tue, Jan 26, 2016 at 12:55 AM, Laura Abbott
> <labbott@fedoraproject.org> wrote:
>> +static bool __page_poisoning_enabled __read_mostly;
>> +static bool want_page_poisoning __read_mostly =
>> +       !IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC);
>> +
>
>
> I would say this patch is nice with regard to decoupling
> CONFIG_DEBUG_PAGEALLOC and CONFIG_PAGE_POISONING.
>
> But  since when we enable CONFIG_DEBUG_PAGEALLOC,
> CONFIG_PAGE_POISONING will be selected.
>
> So it would be better to make page_poison.c totally
> CONFIG_DEBUG_PAGEALLOC agnostic,  in case we latter have
> more PAGE_POISONING users(currently only DEBUG_PAGEALLOC ). How about like this:
>
> +static bool want_page_poisoning __read_mostly =
> +       !IS_ENABLED(CONFIG_PAGE_POISONING );
>
> Or just let it default to 'true',  since we only compile this
> page_poison.c when we enable CONFIG_PAGE_POISONING.
>

This patch was just supposed to be the refactor and keep the existing
behavior. There are no Kconfig changes here and the existing behavior
is to poison if !ARCH_SUPPORTS_DEBUG_PAGEALLOC so I think keeping
what I have is appropriate for this particular patch. This can be
updated in another series if appropriate.

Thanks,
Laura
  
>
> Thanks,
> Jianyu Zhan
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
