Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 397836B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 10:14:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g187so1667836wmg.2
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 07:14:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s2sor512654edh.14.2018.02.11.07.14.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 07:14:36 -0800 (PST)
Date: Sun, 11 Feb 2018 18:14:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm/huge_memory.c: reorder operations in
 __split_huge_page_tail()
Message-ID: <20180211151433.xvza2mugfybyocoi@node.shutemov.name>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
 <151835937752.185602.5640977700089242532.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151835937752.185602.5640977700089242532.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Sun, Feb 11, 2018 at 05:29:37PM +0300, Konstantin Khlebnikov wrote:
> And replace page_ref_inc()/page_ref_add() with page_ref_unfreeze() which
> is made especially for that and has semantic of smp_store_release().

Nak on this part.

page_ref_unfreeze() uses atomic_set() which neglects the situation in the
comment you're removing.

You need at least explain why it's safe now.

I would rather leave page_ref_inc()/page_ref_add() + explcit
smp_mb__before_atomic().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
