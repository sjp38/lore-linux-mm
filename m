Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1D54A6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:26:38 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id p6so3905887qcv.6
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:26:37 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com. [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id f11si28114469qgf.1.2015.01.13.11.26.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 11:26:37 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id a41so2424232yho.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:26:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
Date: Tue, 13 Jan 2015 11:26:36 -0800
Message-ID: <CAJu=L58eMD6yfdo3rKZ_QhSVyQkjKQOpTiboDsmcefYj=0rwYQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] leverage FAULT_FOLL_ALLOW_RETRY in get_user_pages try#2
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Tue, Jan 13, 2015 at 8:37 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Last submit didn't go into -mm/3.19-rc, no prob but here I retry
> (possibly too early for 3.20-rc but I don't expect breakages in this
> area post -rc4) after a rebase on upstream.

The series looks good to me, I didn't spot any material changes from last time.

I would fold patches 3 & 4 together: it's the same idea behind both,
just different parts of the tree.

You could argue also for folding 1 &2 together, the "damage" is done
in 1, 2 as a standalone results in an (IMHO) unnecessarily large diff.

Thanks,
Andres


------ 8< snipping the rest ---------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
