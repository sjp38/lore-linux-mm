Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22AF06B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 21:08:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so10907420lff.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:08:49 -0700 (PDT)
Received: from mail-lf0-x236.google.com (mail-lf0-x236.google.com. [2a00:1450:4010:c07::236])
        by mx.google.com with ESMTPS id o189si43882lff.163.2016.10.20.18.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 18:08:47 -0700 (PDT)
Received: by mail-lf0-x236.google.com with SMTP id b75so112940150lfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:08:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
From: Joel Fernandes <joelaf@google.com>
Date: Thu, 20 Oct 2016 18:08:46 -0700
Message-ID: <CAJWu+opqM8Skgkn0BYR7=kAY8YrHcY+9Ag49nZNEHnmdij8BZw@mail.gmail.com>
Subject: Re: [RFC] reduce latency in __purge_vmap_area_lazy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 17, 2016 at 11:56 PM, Christoph Hellwig <hch@lst.de> wrote:
> Hi all,
>
> this is my spin at sorting out the long lock hold times in
> __purge_vmap_area_lazy.  It is based on the patch from Joel sent this
> week.  I don't have any good numbers for it, but it survived an
> xfstests run on XFS which is a significant vmalloc user.  The
> changelogs could still be improved as well, but I'd rather get it
> out quickly for feedback and testing.

All patches look great to me, and thanks a lot.

Regards,
Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
