Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id A281A6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:41:59 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id m82so107197515oif.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:41:59 -0800 (PST)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com. [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id cp8si21963821oec.98.2016.02.29.07.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 07:41:58 -0800 (PST)
Received: by mail-ob0-x22c.google.com with SMTP id xx9so24768719obc.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 07:41:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1456752417-9626-11-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org> <1456752417-9626-11-git-send-email-mhocko@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 29 Feb 2016 07:41:39 -0800
Message-ID: <CALCETrU-oe6F4iV0Pu1KhEcTtwB-JveqLAcV88R2CP6DVUiRHw@mail.gmail.com>
Subject: Re: [PATCH 10/18] vdso: make arch_setup_additional_pages wait for
 mmap_sem for write killable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch <linux-arch@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On Mon, Feb 29, 2016 at 5:26 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> most architectures are relying on mmap_sem for write in their
> arch_setup_additional_pages. If the waiting task gets killed by the oom
> killer it would block oom_reaper from asynchronous address space reclaim
> and reduce the chances of timely OOM resolving. Wait for the lock in
> the killable mode and return with EINTR if the task got killed while
> waiting.

Acked-by: Andy Lutomirski <luto@kernel.org> # for the x86 vdso

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
