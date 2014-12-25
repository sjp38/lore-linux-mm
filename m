Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3109A6B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 05:25:31 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so31842598obc.1
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 02:25:31 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id k1si8939547oid.128.2014.12.25.02.25.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 02:25:29 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id wo20so31784804obc.13
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 02:25:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1419423766-114457-39-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-39-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 25 Dec 2014 13:25:28 +0300
Message-ID: <CAMo8BfLdm0dRd60ZQ9rROg3QvDR_Zjz0qW31e8LgxyhrsKMCwA@mail.gmail.com>
Subject: Re: [PATCH 38/38] xtensa: drop _PAGE_FILE and pte_file()-related helpers
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, davej@redhat.com, sasha.levin@oracle.com, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 24, 2014 at 3:22 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Max Filippov <jcmvbkbc@gmail.com>
> ---
>  arch/xtensa/include/asm/pgtable.h | 10 ----------
>  1 file changed, 10 deletions(-)

Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
