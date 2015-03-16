Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id BBE826B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:11:25 -0400 (EDT)
Received: by wgra20 with SMTP id a20so50235850wgr.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 14:11:25 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id h5si19970957wie.91.2015.03.16.14.11.24
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 14:11:24 -0700 (PDT)
Date: Mon, 16 Mar 2015 22:11:22 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
Message-ID: <20150316211122.GD11441@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>, Andy Lutomirski <luto@amacapital.net>

On Mon 2015-03-09 23:11:12, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> As pointed by recent post[1] on exploiting DRAM physical imperfection,
> /proc/PID/pagemap exposes sensitive information which can be used to do
> attacks.
> 
> This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
> the pagemap.
> 
> Any comments?
> 
> [1]
http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html

Note that this kind of attack still works without pagemap, it just
takes longer. Actually the first demo program is not using pagemap.

Can we do anything about that? Disabling cache flushes from userland
should make it no longer exploitable.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
