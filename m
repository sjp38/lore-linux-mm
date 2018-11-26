Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECC886B4356
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 14:30:28 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id n26so2455454lfh.13
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:30:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 129sor449518lfl.19.2018.11.26.11.30.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 11:30:26 -0800 (PST)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com. [209.85.208.180])
        by smtp.gmail.com with ESMTPSA id p138sm196054lfp.22.2018.11.26.11.30.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 11:30:24 -0800 (PST)
Received: by mail-lj1-f180.google.com with SMTP id z80-v6so17741805ljb.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:30:24 -0800 (PST)
MIME-Version: 1.0
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Nov 2018 11:30:07 -0800
Message-ID: <CAHk-=wix+0_ED+78Q43Sk+hoObO+Q1DoSOqq_TLnH2=wcNHx2A@mail.gmail.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is migrated
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bhe@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, david@redhat.com, mgorman@techsingularity.net, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, kan.liang@intel.com, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 11:27 AM Hugh Dickins <hughd@google.com> wrote:
>
> +enum behavior {
> +       EXCLUSIVE,      /* Hold ref to page and take the bit when woken, like
> +                        * __lock_page() waiting on then setting PG_locked.
> +                        */
> +       SHARED,         /* Hold ref to page and check the bit when woken, like
> +                        * wait_on_page_writeback() waiting on PG_writeback.
> +                        */
> +       DROP,           /* Drop ref to page before wait, no check when woken,
> +                        * like put_and_wait_on_page_locked() on PG_locked.
> +                        */
> +};

Ack, thanks.

                Linus
