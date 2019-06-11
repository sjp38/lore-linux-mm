Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8077C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E25F2080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:00:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GtnPZ8Pc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E25F2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164076B0266; Tue, 11 Jun 2019 11:00:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 116456B027D; Tue, 11 Jun 2019 11:00:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004B26B027F; Tue, 11 Jun 2019 11:00:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3ED96B0266
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 11:00:22 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id f4so2487407itl.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:00:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zHWTKx49Gq1WGZM8R0zxOjj/6L8rQ+XOzH7iCc71fLE=;
        b=bQ75vFPoZ385cJ3hK8RZp2xcF9nn6Zmbw8wL8c+1dmqeCH81vSfposI95KJZm2XQLE
         kUO03/AiVBM9mhOGukyDoCPQ0YT3VT2Efj3ZcBRslYdCkTcZp2iosSfhqP8ysZO3pO+l
         1+MqccJFZl05ffiUl4ExtBnMMtCToraCB9wxuW+ueN/lwswksi+bDgyhXhV+wtbjJoxA
         On6DtsoaBJ5C0KiBWHFo5YQK4Vu5d92/L0eieknGZCZCyPZRqohivati0gtTsrAKynIe
         U8Nekr/gAZuiC7Z+5by5pxXGZvarxN/+VByijPpxVoLpSW5He5wP6gv4HsK2bxKIRE2g
         Xq4Q==
X-Gm-Message-State: APjAAAVyp3HpE1Iqqol44JLpIBNhz6L8ds/xFwz264dFCp/TfXxWow+4
	wOjtfroDAdaonW7THATJoAdc62MN3Pdsjt9HSvQE27VimG11C0pFm/q1qhA6RD0cxRkoRSiuKRk
	P97fu0Z+FfEiNmUsFzE/g29ZzWxfVB0nF9C2GBSIb9lTsPiQdPIaGp7hCYUA201wk5A==
X-Received: by 2002:a24:5c05:: with SMTP id q5mr19136460itb.110.1560265222643;
        Tue, 11 Jun 2019 08:00:22 -0700 (PDT)
X-Received: by 2002:a24:5c05:: with SMTP id q5mr19136424itb.110.1560265221977;
        Tue, 11 Jun 2019 08:00:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560265221; cv=none;
        d=google.com; s=arc-20160816;
        b=Yai3CVSCQT42Yb5J8w5f424wOzpYi5L/JO+lJeT6u1ISSdbtC24mY5G7xuoYwVJbHV
         ThsJDhQnZoDDvFPnUKbVWOPO0ianyJbwzantbWEGaekNcJMRp+mGXFZiAWBW7bqnaCpg
         7vnafrCBXIKLowyVbeB/I2Sc8A0jqb0flhh4w2qFmmvJDroXMAit5KoQNBTaJr2sumD7
         fMSnj9Kw8tsJlrSenTmfWnlA6Z05oSyb1v2V/6210WTKVdCaBqYxppb3PRsM0mc4vzY2
         OzqxSlWbYNv/H+QzeC+qGCjIJ1tnkCP+XESfo2CRM+HPkc8qJru46KGB6o6E7dYehKA+
         lAjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zHWTKx49Gq1WGZM8R0zxOjj/6L8rQ+XOzH7iCc71fLE=;
        b=Ufh0tf/QAnvPTk9SxfYIC7wHhWtYpzhGSt0epqH2767x3JgcsrlRAAAKth5ji2XKfj
         09iJ0pKyR8hRi7WKgtJXSyMKLijbhdvm/bxrGGNSVigz7+V2vzDIFttj+uUtTjuaDejH
         1XV9d3Q7dFt88Q5E8213NBYTk7SGuZO7wgliVXNuhaHUwAUUkHWtIWTm5WybvTm5nUeL
         VVrq5e2bBqDpQN/G0370fUqk+UGBilWNzem/99T9DN7bi7Gn+f8jG0DAieQB9Hjr1vaC
         4+9j9ifduWFoioAOfl8bRaFvGO2EhCcILwAc3IKEIvH3ZXYrFJrpLtqjf06EiK8vEIsX
         DEOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GtnPZ8Pc;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e195sor3341055itc.3.2019.06.11.08.00.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 08:00:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GtnPZ8Pc;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zHWTKx49Gq1WGZM8R0zxOjj/6L8rQ+XOzH7iCc71fLE=;
        b=GtnPZ8PcYsev3bUJMl12/qtkurUekBfjoeQRssebXZOd1Vh/pi93n8ri1zQygQkkam
         r8WTW+JTL9BiGEGRAzncEEGlp6DxU+Wf6C2V9i0WKb1evjiRaxPojQAHzyyH12bIRb2t
         Kqu59JOKiBKPoa68P04YsCKCLt8DK68jqC194bjmO9/pYj3rNWjlZ/JvgANl1xHzMRFD
         +AyoM1rc7HhX2brUw+Y+e1zOKJcSibWeh6QvI/zRhKNopr0dvUIYrKDu95u4TumCagdE
         rhyAaksXKga9gX1cvnnYe9+KuF69gvZWgDu4ylj2/conJmU/v9a78ph3waARDlWflKST
         7yZw==
X-Google-Smtp-Source: APXvYqz+G5hLirRMGVEg5HuTJI/wTzc5Q/hRbQhchLTgb+mgXtZW3tfRHNTXgv1peMQpp3+2jscWcDy3pmgePdG/+34=
X-Received: by 2002:a24:13d0:: with SMTP id 199mr1095523itz.33.1560265221431;
 Tue, 11 Jun 2019 08:00:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603140304-mutt-send-email-mst@kernel.org>
 <500506fd-7641-c628-533b-7aa178a37f18@redhat.com>
In-Reply-To: <500506fd-7641-c628-533b-7aa178a37f18@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 11 Jun 2019 08:00:10 -0700
Message-ID: <CAKgT0Uem4AJcowHDXPd9yEL8VzA_NciVtWoCiEfsD35q82LF3A@mail.gmail.com>
Subject: Re: [RFC][Patch v10 0/2] mm: Support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 5:19 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 6/3/19 2:04 PM, Michael S. Tsirkin wrote:
> > On Mon, Jun 03, 2019 at 01:03:04PM -0400, Nitesh Narayan Lal wrote:
> >> This patch series proposes an efficient mechanism for communicating free memory
> >> from a guest to its hypervisor. It especially enables guests with no page cache
> >> (e.g., nvdimm, virtio-pmem) or with small page caches (e.g., ram > disk) to
> >> rapidly hand back free memory to the hypervisor.
> >> This approach has a minimal impact on the existing core-mm infrastructure.
> > Could you help us compare with Alex's series?
> > What are the main differences?
> Sorry for the late reply, but I haven't been feeling too well during the
> last week.
>
> The main differences are that this series uses a bitmap to track pages
> that should be hinted to the hypervisor, while Alexander's series tracks
> it directly in core-mm. Also in order to prevent duplicate hints
> Alexander's series uses a newly defined page flag whereas I have added
> another argument to __free_one_page.
> For these reasons, Alexander's series is relatively more core-mm
> invasive, while this series is lightweight (e.g., LOC). We'll have to
> see if there are real performance differences.
>
> I'm planning on doing some further investigations/review/testing/...
> once I'm back on track.

BTW one thing I found is that I will likely need to add a new
parameter like you did to __free_one_page as I need to defer setting
the flag until after all of the merges have happened. Otherwise set
the flag on a given page, and then after the merge that page may not
be the one we ultimately add to the free list.

I'll try to have an update with all of my changes ready before the end
of this week.

Thanks.

- Alex

