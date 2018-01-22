Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5FF9800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:16:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c33so11198794itf.8
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:16:53 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a184sor4859328ith.137.2018.01.22.12.16.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 12:16:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180122092230.42908-1-kirill.shutemov@linux.intel.com>
References: <20180122092230.42908-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 22 Jan 2018 12:16:52 -0800
Message-ID: <CA+55aFxB_+qyhxaQB7EucJ7e3JO5nJjX=ewBYttmT4gFZSHGtA@mail.gmail.com>
Subject: Re: [PATCH] mm, page_vma_mapped: Introduce pfn_in_hpage()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jan 22, 2018 at 1:22 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> The new helper would check if the pfn belongs to the page. For huge
> pages it checks if the PFN is within range covered by the huge page.
>
> The helper is used in check_pte(). The original code the helper replaces
> had two call to page_to_pfn(). page_to_pfn() is relatively costly.
>
> Although current GCC is able to optimize code to have one call, it's
> better to do this explicitly.

Thanks, I applied it directly, since your page_vma_mapped fix was
still my top commit, and I asked for this cleanup.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
