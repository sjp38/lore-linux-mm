Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B64AC6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:32:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k12so92415313lfb.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:32:41 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id g1si14888571wjx.59.2016.09.12.04.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 04:32:40 -0700 (PDT)
Date: Mon, 12 Sep 2016 13:32:38 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] PM / Hibernate: allow hibernation with
 PAGE_POISONING_ZERO
Message-ID: <20160912113238.GA30927@amd>
References: <1473410612-6207-1-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473410612-6207-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: linux-mm@kvack.org, linux-pm@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Laura Abbott <labbott@fedoraproject.org>, Mel Gorman <mgorman@suse.de>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Jianyu Zhan <nasa4836@gmail.com>, Kees Cook <keescook@chromium.org>, Len Brown <len.brown@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mathias Krause <minipli@googlemail.com>, Michal Hocko <mhocko@suse.com>, PaX Team <pageexec@freemail.hu>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Yves-Alexis Perez <corsac@debian.org>, linux-kernel@vger.kernel.org

On Fri 2016-09-09 10:43:32, Anisse Astier wrote:
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

Looks reasonable to me.

Acked-by: Pavel Machek <pavel@ucw.cz>

Actually.... this takes basically zero time come. Do we want to do it
unconditionally?

(Yes, it is free memory, but for sake of debugging, I guess zeros are
preffered to random content that changed during hibernation.)

(But that does not change the Ack.)

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
