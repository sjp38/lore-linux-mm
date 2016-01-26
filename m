Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id D5DBA6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:27:04 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id p187so102754193oia.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:27:04 -0800 (PST)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id d191si20852862oig.35.2016.01.25.22.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 22:27:04 -0800 (PST)
Received: by mail-oi0-x243.google.com with SMTP id a202so8523967oib.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 22:27:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453740953-18109-2-git-send-email-labbott@fedoraproject.org>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org> <1453740953-18109-2-git-send-email-labbott@fedoraproject.org>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 26 Jan 2016 14:26:24 +0800
Message-ID: <CAHz2CGXuUHYHX7KhxGjYtWrKOoxK=2Rz2N-Q0CBR9UWtrYi2Jw@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/3] mm/debug-pagealloc.c: Split out page poisoning
 from debug page_alloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Tue, Jan 26, 2016 at 12:55 AM, Laura Abbott
<labbott@fedoraproject.org> wrote:
> +static bool __page_poisoning_enabled __read_mostly;
> +static bool want_page_poisoning __read_mostly =
> +       !IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC);
> +


I would say this patch is nice with regard to decoupling
CONFIG_DEBUG_PAGEALLOC and CONFIG_PAGE_POISONING.

But  since when we enable CONFIG_DEBUG_PAGEALLOC,
CONFIG_PAGE_POISONING will be selected.

So it would be better to make page_poison.c totally
CONFIG_DEBUG_PAGEALLOC agnostic,  in case we latter have
more PAGE_POISONING users(currently only DEBUG_PAGEALLOC ). How about like this:

+static bool want_page_poisoning __read_mostly =
+       !IS_ENABLED(CONFIG_PAGE_POISONING );

Or just let it default to 'true',  since we only compile this
page_poison.c when we enable CONFIG_PAGE_POISONING.


Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
