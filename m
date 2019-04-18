Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6338C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 10:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 599F6217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 10:44:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GeETOI+n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 599F6217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5CDE6B0269; Thu, 18 Apr 2019 06:44:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E325C6B026A; Thu, 18 Apr 2019 06:44:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22706B026B; Thu, 18 Apr 2019 06:44:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id B013C6B0269
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:44:21 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id v7so358634vsc.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 03:44:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=j/effP+5iohMRocuBbn+wU3ZjTEdFsXMtMXgMIyP5mQ=;
        b=eIf5JWF7g8leDlQx/IXDLU6KaCiTckj1hXoCVG+4/cJGCkfXcaFHqHGzvD6vC4vLiA
         JXxI59v2yrB0Y7hS3o/ReMatFCnZJkUKoyaEmy7DgpxyTztL7L6m1JxfFQEHuN/brJVh
         ZcyG4FV3Kn/XN4TLGNmnqkjoaIKDpNWJH8H9RRGJrG3fxnDRmT4OOsXCHTVrfiKQ7SBl
         o8h9ChhPMFneXF7N1/ZZOmPaXWdH/nUPB1HwIcQv2ez+SSSoHeHOXZ674XKS9UkSBtrJ
         5XxQmoy8hMV5EUtqqdMNh6PSFhr2+bOFxNurhzW9tFdSZZBL1QASV2jxi8H//aUJdf/F
         IHYA==
X-Gm-Message-State: APjAAAV978DDQYCMDXQptRWmhd9doKQ/FZ3B+Mxjj3hIAxrkk0nvo8LC
	Vn6O/u0q3+3vXmKD36BcaKrZnuHlgt+HNWTvTtv8c3MppEH21lo/QQXBKCkuTp8ABgYxos4cG++
	ok2olmTM5uTfWvt39GH20aaFmHd7GR0jO53O33ta19H2xK+mXiUFmI94HAdGSYuA6yg==
X-Received: by 2002:a67:f753:: with SMTP id w19mr51149973vso.27.1555584261401;
        Thu, 18 Apr 2019 03:44:21 -0700 (PDT)
X-Received: by 2002:a67:f753:: with SMTP id w19mr51149958vso.27.1555584260738;
        Thu, 18 Apr 2019 03:44:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555584260; cv=none;
        d=google.com; s=arc-20160816;
        b=b7i1Sk283wbXEd+ooZ0n91QGmQ00uInkjzsj/wvAnakNtLynTGJ4Lo75hge22gSzaV
         4DaV+X7Lm93UvZNUZi7miS+xgmpvL3wmfvPRTwJTvX3mPq1PunziRh4CAcDs/cVd3QsI
         ZLe2r0Er8AlQUncvZ2RwGDSQDIKzo3k9G1HRbO3kYZ+wMXdlf28P7/VpPGItQuP240u4
         KbuO7oSntw5Qj/IyPZIXbiS1aZSgZPisIgwC5KruMErZTzy6uHhciO3bp7HhMwyd0QaO
         8zDVmcd8ARmhhbhbja+1FL8E95MAIM2iAK0W9ZQxd6DLIJ8uKYxrZzYjH5dCVfhRLL5H
         ScwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=j/effP+5iohMRocuBbn+wU3ZjTEdFsXMtMXgMIyP5mQ=;
        b=0oDHEhPeOEJJTvYjj9tsC/ztfwF407hHZQsmFl2mjFMuzp9Io8t8jAf12azkQCZHcu
         FgrrF0C2rB0H5g5NxB1rhoNRUgyvUYs79e2RW/7fD3aa2B2KYqzTcD4qcejjJOpoAfVi
         9RFBohMKn0UVM+35t5+lHmtsw58/lyqxpQY9ftV6cgXupTJziUoEHuap/SuHzcjYbXqm
         MX28FV64FYpjLG+Inrxqw88CovXt643+aZHFanVCAGBtWi0YAhjRaMfiLUOwgOztlM17
         II9KAslNL9xgQNsLd2F1mNsjThFKCHDli7ysXcsmPbU6WuaZ2tzgolo6Zmp2RmzLpp7y
         GT7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GeETOI+n;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16sor823042uao.8.2019.04.18.03.44.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 03:44:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GeETOI+n;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=j/effP+5iohMRocuBbn+wU3ZjTEdFsXMtMXgMIyP5mQ=;
        b=GeETOI+nF6LsuhqqtpSuoChbWH/UskTP93w2FqBAJ8suHcg5eru1GG26pM34rRqRIv
         B8WSV1vIoO/1nGhFp6RzC7tRx+dg46QqHS/n6VfCLXfkss6Wl+7f6WCCoYzQtCpy+Av9
         pK71SoS6mO5cCMQXP104i5sSYKE6Geh5ETamcgF6x60B8GK8filcjyPyvI1JHUkVFbsp
         MRDJlfZlESNOiFomQ0iE/paycPL/z00zxILDRgJ6z1hxx7TvFI07lkZ5PWG4KQ2p+24S
         lvWoZBjFQXQxvOE/FjegXCDh94aPaBSMmWJHMZZRUS76gPsOv6u8DX3QMmM3Wley22js
         9giQ==
X-Google-Smtp-Source: APXvYqwaHpp8DFAXY794irwZcMMDgalNDbI2Y+3MtD4mgFCui2zslWAkxHIQQmiBGvEI1Mqv5l7PN3Bzezpz5W4/g08=
X-Received: by 2002:ab0:44e:: with SMTP id 72mr49531989uav.110.1555584260078;
 Thu, 18 Apr 2019 03:44:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190418084119.056416939@linutronix.de> <20190418084254.361284697@linutronix.de>
In-Reply-To: <20190418084254.361284697@linutronix.de>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 18 Apr 2019 12:44:08 +0200
Message-ID: <CAG_fn=WP9+bVv9hedoaTzWK+xBzedxaGJGVOPnF0o115s-oWvg@mail.gmail.com>
Subject: Re: [patch V2 14/29] dm bufio: Simplify stack trace retrieval
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org, 
	Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, dm-devel@redhat.com, 
	Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
	Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>, 
	iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>, 
	Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, 
	Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, 
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, 
	intel-gfx@lists.freedesktop.org, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, 
	David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, 
	Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 11:06 AM Thomas Gleixner <tglx@linutronix.de> wrote=
:
>
> Replace the indirection through struct stack_trace with an invocation of
> the storage array based interface.
>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: dm-devel@redhat.com
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: Alasdair Kergon <agk@redhat.com>
> ---
>  drivers/md/dm-bufio.c |   15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)
>
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -150,7 +150,7 @@ struct dm_buffer {
>         void (*end_io)(struct dm_buffer *, blk_status_t);
>  #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
>  #define MAX_STACK 10
> -       struct stack_trace stack_trace;
> +       unsigned int stack_len;
>         unsigned long stack_entries[MAX_STACK];
>  #endif
>  };
> @@ -232,11 +232,7 @@ static DEFINE_MUTEX(dm_bufio_clients_loc
>  #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
>  static void buffer_record_stack(struct dm_buffer *b)
>  {
> -       b->stack_trace.nr_entries =3D 0;
> -       b->stack_trace.max_entries =3D MAX_STACK;
> -       b->stack_trace.entries =3D b->stack_entries;
> -       b->stack_trace.skip =3D 2;
> -       save_stack_trace(&b->stack_trace);
> +       b->stack_len =3D stack_trace_save(b->stack_entries, MAX_STACK, 2)=
;
As noted in one of similar patches before, can we have an inline
comment to indicate what does this "2" stand for?
>  }
>  #endif
>
> @@ -438,7 +434,7 @@ static struct dm_buffer *alloc_buffer(st
>         adjust_total_allocated(b->data_mode, (long)c->block_size);
>
>  #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
> -       memset(&b->stack_trace, 0, sizeof(b->stack_trace));
> +       b->stack_len =3D 0;
>  #endif
>         return b;
>  }
> @@ -1520,8 +1516,9 @@ static void drop_buffers(struct dm_bufio
>                         DMERR("leaked buffer %llx, hold count %u, list %d=
",
>                               (unsigned long long)b->block, b->hold_count=
, i);
>  #ifdef CONFIG_DM_DEBUG_BLOCK_STACK_TRACING
> -                       print_stack_trace(&b->stack_trace, 1);
> -                       b->hold_count =3D 0; /* mark unclaimed to avoid B=
UG_ON below */
> +                       stack_trace_print(b->stack_entries, b->stack_len,=
 1);
> +                       /* mark unclaimed to avoid BUG_ON below */
> +                       b->hold_count =3D 0;
>  #endif
>                 }
>
>
>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

