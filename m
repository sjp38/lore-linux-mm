Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D821800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 20:49:32 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id o66so8815707ita.3
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 17:49:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m186sor3929033itd.0.2018.01.21.17.49.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jan 2018 17:49:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801212349.w0LNna1E022604@www262.sakura.ne.jp>
References: <20180119124924.25642-1-kirill.shutemov@linux.intel.com>
 <CA+55aFxobYQ5cqnCZuf8xVWr3hCUmg=rTxDPV3zHWqeQysVkxA@mail.gmail.com> <201801212349.w0LNna1E022604@www262.sakura.ne.jp>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 21 Jan 2018 17:49:30 -0800
Message-ID: <CA+55aFzSV_XPv8UBPVKnppeJ3cCeibQxzKvRDjFDJUBBJvXP=w@mail.gmail.com>
Subject: Re: [PATCHv2] mm, page_vma_mapped: Drop faulty pointer arithmetics in check_pte()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>

On Sun, Jan 21, 2018 at 3:49 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> As far as I tested, using helper function made no difference. Unless I
> explicitly insert barriers like cpu_relax() or smp_mb() between these,
> the object side does not change.

Ok, thanks for checking.

> You can apply with
>
>   Acked-by: Michal Hocko <mhocko@suse.com>
>   Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Applied and pushed out. Thanks everybody.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
