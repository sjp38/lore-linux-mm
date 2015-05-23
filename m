Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1031882A1F
	for <linux-mm@kvack.org>; Sat, 23 May 2015 06:54:33 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so9925770wic.0
        for <linux-mm@kvack.org>; Sat, 23 May 2015 03:54:32 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id ha2si2715876wib.48.2015.05.23.03.54.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 May 2015 03:54:31 -0700 (PDT)
Received: by wichy4 with SMTP id hy4so10129939wic.1
        for <linux-mm@kvack.org>; Sat, 23 May 2015 03:54:30 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <555fa43a.O+VvdA70yRRjg8LR%akpm@linux-foundation.org>
References: <555fa43a.O+VvdA70yRRjg8LR%akpm@linux-foundation.org>
Date: Sat, 23 May 2015 12:54:30 +0200
Message-ID: <CA+icZUXRs0ShGqn1232kdwvwpsX1UWzocKhshhV=AC1gPedu5Q@mail.gmail.com>
Subject: Re: mmotm 2015-05-22-14-48 uploaded
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.cz>

On Fri, May 22, 2015 at 11:48 PM,  <akpm@linux-foundation.org> wrote:
[...]
> You will need quilt to apply these patches to the latest Linus release (3.x
> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
>
[...]

Should be updated to "4.x" and "4.x-rcY".

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
