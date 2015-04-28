Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB5B6B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 08:12:14 -0400 (EDT)
Received: by wgin8 with SMTP id n8so148914659wgi.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:12:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h8si38166973wjs.46.2015.04.28.05.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 05:12:11 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
Date: Tue, 28 Apr 2015 14:11:48 +0200
Message-Id: <1430223111-14817-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20150114095019.GC4706@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Hi,
it seems that the initial email got lost (or ignored). I would like to
revive it again. I've cooked up a potential fix to this issue which will
follow as a reply to this email.

The first patch is dumb and straightforward. It should be safe as is and
also good without the follow up 2 patches which try to handle potential
allocation failures in the do_munmap path more gracefully. As we still
do not fail small allocations even the first patch could be simplified
a bit and the retry loop replaced by a BUG_ON right away. But I felt this
would better be done robust.

An obvious alternative would be patching the man pages to mention the
subtle difference between mlock and MAP_LOCKED semantic. I have checked
debian code search and it shown some applications relying on MAP_LOCKED
but I have no idea whether they really require the mlock all-or-nothing
fault in semantic.

Any thoughts, ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
