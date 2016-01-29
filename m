Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4593A6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:45:54 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 128so47266037wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:45:54 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id 190si10157574wmh.45.2016.01.29.02.45.53
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 02:45:53 -0800 (PST)
Date: Fri, 29 Jan 2016 11:45:43 +0100
From: Pavel Machek <pavel@denx.de>
Subject: Re: [PATCHv2 2/2] mm/page_poisoning.c: Allow for zero poisoning
Message-ID: <20160129104543.GA21224@amd>
References: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
 <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, linux-pm@vger.kernel.org

Hi!

> By default, page poisoning uses a poison value (0xaa) on free. If this
> is changed to 0, the page is not only sanitized but zeroing on alloc
> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
> corruption from the poisoning is harder to detect. This feature also
> cannot be used with hibernation since pages are not guaranteed to be
> zeroed after hibernation.

So... this makes kernel harder to debug for performance advantage...?
If so.. how big is the performance advantage?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
