Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3703C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82F592173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UTzC65bg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82F592173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 258268E0007; Thu, 18 Jul 2019 16:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207678E0001; Thu, 18 Jul 2019 16:54:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F5FE8E0007; Thu, 18 Jul 2019 16:54:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E37458E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:54:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so24276637qkl.7
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:54:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7emRYoT5fb8r2z6gXsWHsiNYUTpTl/PouMaFyVOjnww=;
        b=QaqxUWaPDhuhFCemG0SVyUGg18rGtd/3aYn1xNqM1IOo4ADmi6F5ugujHY9uusMWuF
         mBuDeB8d/xEHTl2S+pbgn3NvBQ8AkMBNciyjPJ3WFbbWg/uziw7ACiQwryMCoGzmCP7M
         gLEmbZUnE0z5aAXG0LIG5JMj7mptXtBUeGP5TW60jyPc3yqZKwoxq03VPL6cX1T5dI3f
         zO3Pfs2JvMxmb19zzaSif4OT0cfOjiHfmV2SiUZzuuac59K1eVEgYrifbS8pYECH1DOJ
         LAyIuF0Y9PS+fiigJA2ez9mnL73CxV1gD8dD+B1Z2Q4z3+bvFQvJ0yEpKhTjGaAp30/s
         F/Jw==
X-Gm-Message-State: APjAAAVoQARSbtSiQfevbNEps+zqhpAfxI+15Pn+ifKuvhjCA45FIDgP
	QF+jO4twkEA32iGpsfnwJEkpm1BQvlqTFLVNLsZwajAseRYLWc75mNtBiQTGXlJMBQtyRr2nnT7
	b84RDGw8zykgyyoaANCC+Sn9YQ6pCpwodqdN2NUlezgC+HOHIyq61A8mUagdlysQ4cQ==
X-Received: by 2002:ac8:525a:: with SMTP id y26mr33897872qtn.378.1563483267718;
        Thu, 18 Jul 2019 13:54:27 -0700 (PDT)
X-Received: by 2002:ac8:525a:: with SMTP id y26mr33897851qtn.378.1563483267136;
        Thu, 18 Jul 2019 13:54:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563483267; cv=none;
        d=google.com; s=arc-20160816;
        b=cUkJ+tultxXwzobpIiWtKG8Grp3pgFaWH7KEMTkUvAyh4w+EqMJnKjOp6G/M7PMQpY
         OOUnhNaU7qngpiVEsMfcqBMSmx/w5Jsa6CPAEjUyw/MPZyhGnXJqIgjVBrBKk0CqLEZz
         BmqhycbSAHA9tF3DUTsmifXNxTcH5F7J5WeKa6p3MqdIwvbvdMvcEF9M0oh1QSm2qysi
         nVdB2kMEV3d0vjpi/k24bSvA6auyc7is9nkV+5Z1oD+vbsBiBPABH0+1xF5wMQOpXh3z
         +M6Ju6bew9pjuyBs3qgFk4ML6EvIPgJ77IR1Y4YZOe6uivv4vnsOWYzQGUrHIL1DdU2G
         BgMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7emRYoT5fb8r2z6gXsWHsiNYUTpTl/PouMaFyVOjnww=;
        b=ZrXDMONDP4uHAWIl2WlrjWw3cUnsnpLbt4aJULUgUq2IbWAQJSuMug/4ICxv7OhSGn
         LtgpHLt66/H0/a+imkdimHtI6OsyS9a8sIdh/1e+AL91Z8yZr6FbfKyCroNuATiHqqHW
         Vw4RKrrrd/KGyBj8ZWkaBbFuxT5Cd57I+f6P1AxROj7Rjc5sjHeb96xC3ktV6OTH4Utp
         GnoHP+LcbtkAUAuSu6l5SnfbBGjJ9EXsveHjeORsARt4HlqkAMqu2m4gWHY1HoNxwYk6
         HnhFI8+8GP6r0cuDXX4B3rKR2r+kRPQAw+t0UUxvVgR0PsoWJOIRnXkWRxQhzp9lOf4D
         8Adw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UTzC65bg;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 202sor16995642qkf.157.2019.07.18.13.54.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 13:54:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UTzC65bg;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7emRYoT5fb8r2z6gXsWHsiNYUTpTl/PouMaFyVOjnww=;
        b=UTzC65bgSmS0ZVhgdWSoC3T5DMUpzjrxwzvNfIMglsBH1bv2RR184lr6xU7FEpxEwW
         rGcf8KKjlzepDJvuwOk+V7PacziM1Wa46b0Mda1ESFrVemjZtCu3R+3xko8BvfDtYqlg
         NsDu1s5waBUWJQIa+G4+mxanK2mzuA1uLYeDJ0YmKMpRgfFIDKYzNcRSMbNdAPxdNVly
         NAMdVsTdSkjj0OK4oeOSEVmTagAyQ0jo8t/q6CXLUvBEVqDWnX1rqmORNv6VJpEhAiIj
         sf1FZZBwqUMSvo1ik1WbhMkklOPSy7WXWxxCMV3zSbp8gHG/NRQDvDwKM51n95pq/Bvk
         h9jw==
X-Google-Smtp-Source: APXvYqzCbtKw7lABM5d7gtaXQR8QpjKah4ysVH7vLjkBhNJeiCYXH0PXPFpR/DGO1YaYtTEaiy/hYhgQ9cACF4oYkSQ=
X-Received: by 2002:a37:7ec1:: with SMTP id z184mr32664238qkc.491.1563483266795;
 Thu, 18 Jul 2019 13:54:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org> <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org> <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org> <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718113548-mutt-send-email-mst@kernel.org> <CAKgT0UeRy2eHKnz4CorefBAG8ro+3h4oFX+z1JY2qRm17fcV8w@mail.gmail.com>
 <20190718163325-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718163325-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 18 Jul 2019 13:54:15 -0700
Message-ID: <CAKgT0UcFqYm-b1zh4UT8m=3gi950T0c-gsxjhszeVgANfKQCRA@mail.gmail.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 1:37 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Jul 18, 2019 at 01:29:14PM -0700, Alexander Duyck wrote:
> > So one thing that is still an issue then is that my approach would
> > only work on the first migration. The problem is the logic I have
> > implemented assumes that once we have hinted on a page we don't need
> > to do it again. However in order to support migration you would need
> > to reset the hinting entirely and start over again after doing a
> > migration.
>
> Well with precopy at least it's simple: just clear the
> dirty bit, it won't be sent, and then on destination
> you get a zero page and later COW on first write.
> Right?

Are you talking about adding MADV_DONTNEED functionality to FREE_PAGE_HINTS?

> With precopy it is tricker as destination waits until it gets
> all of memory. I think we could use some trick to
> make source pretend it's a zero page, that is cheap to send.

So I am confused again.

What I was getting at is that if I am not mistaken block->bmap is set
to all 1s for each page in ram_list_init_bitmaps(). After that the
precopy starts and begins moving memory over. We need to be able to go
in and hint away all the free pages from that initial bitmap. To do
that we would need to have the "Hinted" flag I added in the patch set
cleared for all pages, and then go through all free memory and start
over in order to hint on which pages are actually free. Otherwise all
we are doing is hinting on which pages have been freed since the last
round of hints.

Essentially this is another case where being incremental is
problematic for this design. What I would need to do is reset the
"Hinted" flag in all of the free pages after the migration has been
completed.

