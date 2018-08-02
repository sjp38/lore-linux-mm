Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 428066B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 02:57:35 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id w7-v6so304052ljh.15
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 23:57:35 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id h17-v6si464092lfi.68.2018.08.01.23.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 23:57:33 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm: workingset: tell cache transitions from
 workingset thrashing
References: <20180801151308.32234-1-hannes@cmpxchg.org>
 <20180801151308.32234-3-hannes@cmpxchg.org>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <c0480401-fb38-0b46-6dee-a20093dff065@sony.com>
Date: Thu, 2 Aug 2018 08:57:31 +0200
MIME-Version: 1.0
In-Reply-To: <20180801151308.32234-3-hannes@cmpxchg.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 08/01/2018 05:13 PM, Johannes Weiner wrote:
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index e34a27727b9a..7af1c3c15d8e 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -69,13 +69,14 @@
>   */
>  enum pageflags {
>  	PG_locked,		/* Page is locked. Don't touch. */
> -	PG_error,
>  	PG_referenced,
>  	PG_uptodate,
>  	PG_dirty,
>  	PG_lru,
>  	PG_active,
> +	PG_workingset,
>  	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
> +	PG_error,
>  	PG_slab,
>  	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
>  	PG_arch_1,
> @@ -280,6 +281,8 @@ PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
Any reason why the PG_error was moved? And dont you need to do some handling of this flag in proc/fs/page.c ?
Some KFP_WORKINGSET ?
