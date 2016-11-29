Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE2B6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:34:01 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id 98so73586398lfs.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:34:01 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id y10si30299550lja.26.2016.11.29.14.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:34:00 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id p100so14070167lfg.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:33:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
References: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 29 Nov 2016 17:33:19 -0500
Message-ID: <CALZtONCzseKs22189B3b+TEPKu8JPQ4WcGGB0zPj4KNuKiUAig@mail.gmail.com>
Subject: Re: [PATCH 0/2] z3fold fixes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

On Sat, Nov 26, 2016 at 2:15 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Here come 2 patches with z3fold fixes for chunks counting and locking. As=
 commit 50a50d2 ("z3fold: don't fail kernel build is z3fold_header is too b=
ig") was NAK'ed [1], I would suggest that we removed that one and the next =
z3fold commit cc1e9c8 ("z3fold: discourage use of pages that weren't compac=
ted") and applied the coming 2 instead.

Instead of adding these onto all the previous ones, could you redo the
entire z3fold series?  I think it'll be simpler to review the series
all at once and that would remove some of the stuff from previous
patches that shouldn't be there.

If that's ok with Andrew, of course, but I don't think any of the
z3fold patches have been pushed to Linus yet.

>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>
> [1] https://lkml.org/lkml/2016/11/25/595

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
