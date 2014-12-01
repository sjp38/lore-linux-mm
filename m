Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1D86B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 11:47:47 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so8043032qcz.10
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 08:47:47 -0800 (PST)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id a18si15561815qai.69.2014.12.01.08.47.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 08:47:46 -0800 (PST)
Received: by mail-qc0-f169.google.com with SMTP id w7so7969566qcr.14
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 08:47:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
Date: Mon, 1 Dec 2014 08:47:45 -0800
Message-ID: <CA+55aFxRvL9qtCLTTCZZ-kus4yQjFRp_NSZcB1bdB_LJ-qBtow@mail.gmail.com>
Subject: Re: [PATCH 0/5] Refactor do_wp_page, no functional change
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Haggai Eran <haggaie@mellanox.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Sagi Grimberg <sagig@mellanox.com>, Michel Lespinasse <walken@google.com>

On Mon, Dec 1, 2014 at 4:04 AM, Shachar Raindel <raindel@mellanox.com> wrote:
>
> The patches have been tested using trinity on a KVM machine with 4
> vCPU, with all possible kernel debugging options enabled. So far, we
> have not seen any regressions. We have also tested the patches with
> internal tests we have that stress the MMU notifiers, again without
> seeing any issues.

Looks good. Please take Kirill's feedback, but apart from that:

  Acked-by: Linus Torvalds <torvalds@linux-foundation.org>

(I assume this will come in through -mm as usual - Andrew, holler if not).

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
