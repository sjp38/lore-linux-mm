Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F23C36B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 20:54:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b187so842741wme.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 17:54:21 -0700 (PDT)
Received: from cloudserver094114.home.net.pl (cloudserver094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id l12si1433267wmb.146.2016.09.13.17.54.20
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 17:54:20 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH] PM / Hibernate: allow hibernation with PAGE_POISONING_ZERO
Date: Wed, 14 Sep 2016 03:00:29 +0200
Message-ID: <1856521.PhkV49ibzK@vostro.rjw.lan>
In-Reply-To: <1473410612-6207-1-git-send-email-anisse@astier.eu>
References: <1473410612-6207-1-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: linux-mm@kvack.org, linux-pm@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Laura Abbott <labbott@fedoraproject.org>, Mel Gorman <mgorman@suse.de>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Jianyu Zhan <nasa4836@gmail.com>, Kees Cook <keescook@chromium.org>, Len Brown <len.brown@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mathias Krause <minipli@googlemail.com>, Michal Hocko <mhocko@suse.com>, PaX Team <pageexec@freemail.hu>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Yves-Alexis Perez <corsac@debian.org>, linux-kernel@vger.kernel.orgKees Cook <keescook@chromium.org>Pavel Machek <pavel@ucw.cz>

On Friday, September 09, 2016 10:43:32 AM Anisse Astier wrote:
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

Applied (with the tags from Pavel and Kees).

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
