Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8213C6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 14:29:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id g141so19647585wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:29:51 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id ql8si4146209wjc.120.2016.09.09.11.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 11:29:50 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id b187so45508727wme.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:29:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473410612-6207-1-git-send-email-anisse@astier.eu>
References: <1473410612-6207-1-git-send-email-anisse@astier.eu>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 9 Sep 2016 11:29:49 -0700
Message-ID: <CAGXu5jLP2NmuN17HraJw2iLLB=5w=mb6-bTOpSECK_ai1ifjEg@mail.gmail.com>
Subject: Re: [PATCH] PM / Hibernate: allow hibernation with PAGE_POISONING_ZERO
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>, Laura Abbott <labbott@fedoraproject.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Jianyu Zhan <nasa4836@gmail.com>, Len Brown <len.brown@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mathias Krause <minipli@googlemail.com>, Michal Hocko <mhocko@suse.com>, PaX Team <pageexec@freemail.hu>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Yves-Alexis Perez <corsac@debian.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 9, 2016 at 1:43 AM, Anisse Astier <anisse@astier.eu> wrote:
> PAGE_POISONING_ZERO disables zeroing new pages on alloc, they are
> poisoned (zeroed) as they become available.
> In the hibernate use case, free pages will appear in the system without
> being cleared, left there by the loading kernel.
>
> This patch will make sure free pages are cleared on resume when
> PAGE_POISONING_ZERO is enabled. We free the pages just after resume
> because we can't do it later: going through any device resume code might
> allocate some memory and invalidate the free pages bitmap.
>
> Thus we don't need to disable hibernation when PAGE_POISONING_ZERO is
> enabled.
>
> Signed-off-by: Anisse Astier <anisse@astier.eu>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Laura Abbott <labbott@fedoraproject.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rafael J. Wysocki <rjw@rjwysocki.net>

Cool!

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
