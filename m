Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2074AC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCA9721019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 07:09:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p49ChQ13"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCA9721019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 795716B0266; Wed, 29 May 2019 03:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71F066B026A; Wed, 29 May 2019 03:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6816B026B; Wed, 29 May 2019 03:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA8AB6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 03:09:40 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m2so433072lfj.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 00:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0hmEt8XBAszMFOt/NHrMak9iR4Ln+O6rhKTThaepQX0=;
        b=hQKpenvwPqGTwtXyG8cn5TmCm/toyxyjuEgTWnhLI9Pjlq4v+3OCQeb+QtvFExzVMI
         t/4nrikgL+2piYUOWs7yqQFQRXOr94wFGevaRyV0+dEm2zeW8FYPaMgqhXcDz3HhL1Wl
         AbCbq3P7jzMmCwau5KrUqulcqrEeGxsEzNwQt1eZHQRjlbPr0Si00qvTT3ibhVDrcl7W
         orJ4XrO40E43cX7gDqPDwE8R0iE2LKoQfskl3k3rfvROEHBMFHc+zVtNMEm7xdppaSGg
         HBzmgvQcNwEAJnkKXsdXVV6cm7x6HvQIBSCpKZPpYV4qcJ7hpWC5dMfQ6YQebYklk8rj
         +LKQ==
X-Gm-Message-State: APjAAAUD/RZ3n4YfzT+rUVNtuLt6/3KzwhywRRIBT4zgPBTjXhquh7Eq
	VW8qXD01cN5hD4013kuDfLcKSKTyNiZSuBvltmpRMscfdxvb9RuMyGlNvDzOD7f1dWYRvUbCfPD
	6a8wii4T/LaD/BP/7lKCiSxv4zM7D0PzCfam9B6JvSennEyC7tGcVpyFVLxiMPnzxCg==
X-Received: by 2002:a2e:880d:: with SMTP id x13mr26572333ljh.72.1559113780075;
        Wed, 29 May 2019 00:09:40 -0700 (PDT)
X-Received: by 2002:a2e:880d:: with SMTP id x13mr26572297ljh.72.1559113779278;
        Wed, 29 May 2019 00:09:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559113779; cv=none;
        d=google.com; s=arc-20160816;
        b=yixcWUTH1N9umJN3A0XhQq1L2YpxO5YL1AE8cWUnQ6jiJtB8M49AT8bT4rrXwBc1Mk
         gkvltP9NtPhRONtuKb3MQGLEsW+B0NHc7bEpJHHBRiDh1Fj51Vuy/5VcK7JgilZqWnU7
         AaDLBLaLyhAjtUKUts15wpYHwiKvjSmj2TqBnCBKBA/tsrKyGqJ3/H8t7RepLsz4gWtf
         ET8OHne9sEZZlFd96nkhPkB8MX7K5pp5Gagu264b+VmmGPrdsPTDyEv64we5QJNub2SO
         3O8ZBPANtdEGqFWFf3J3g375DC3ztUQSSBa2+HynNuyE9PQ0DnrFzXD2lQR0fH3EHmbs
         3mZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0hmEt8XBAszMFOt/NHrMak9iR4Ln+O6rhKTThaepQX0=;
        b=MvK6HjmnDFAl1P6fPWIPlbSUbGRhLteKZ2xVgR0Cahm1J5jDT0868FcaoQAd4X+kFb
         FIVBDCgo/8jTeRfPyprVnDjKxGoOwICbT/6AKAAT2wkLp3YhQQetJJniA0VfoYAo37tr
         dA66NLsqn2QnojolP9P80O3zjCRVdei0SY4w1DCwJdadkJ36zY35jG0P1X9x/ABYnuiR
         sYYEn6r6SwpSq6kHTHH2VB/DMOmFnl9LF6pGNeyKplj4QwzS5gQYXn2qpgQTTW1qDf6Y
         DyEfsMdb4S3gPZdvZqaCHA5LS2lVA0XCQVgIZxV2AUODhrs9W7MnCvQm4mkiN5BMmQKP
         yi0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p49ChQ13;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r26sor2427184ljb.10.2019.05.29.00.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 00:09:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p49ChQ13;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0hmEt8XBAszMFOt/NHrMak9iR4Ln+O6rhKTThaepQX0=;
        b=p49ChQ13CkTgafcWq6Mx8FOk/3a/AeGpi05o5uxn0TRjMP7yQKQUwXpN1bbkt6bsUL
         BOp03/oTIkbFDCJgo8EFfNE0dDIo9i7rKReMyFNF1dZ/M1Tga6IFPJqU6RNwQ9ztAKEi
         kVPSOn09OJUcGey1NdvjzyLfUrSxYu2LvzfPCvj/ykDhrPxYoFREu8hf7+IFKkVuznxg
         wzzsesZ5sTsck6PUx8smbK+YfBzvT0kXI2A1La8N2CmQUuFn1pR26ai5oseyyE1t//7M
         Jp5OBTnFMGRX4xsL05DMLjI183G/vREXuSDRD9tAOSzGCVHCv3Od22rktQlI1NPK0/Wh
         hWLQ==
X-Google-Smtp-Source: APXvYqzPybpE3leNNpeYsxD/syHNbqQB4AamoUBooFN787Z8X3jpIs8qqKLWY3d8qJDJTDSMGWjIGZogbhlUDWuIO+4=
X-Received: by 2002:a2e:9dc6:: with SMTP id x6mr1537784ljj.27.1559113778900;
 Wed, 29 May 2019 00:09:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190528193004.GA7744@gmail.com>
In-Reply-To: <20190528193004.GA7744@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 29 May 2019 12:39:27 +0530
Message-ID: <CAFqt6zZ0SHXddLoQMoO3LHT=50Br0x4r3Wn4XviypRxRUtn9zQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Fail when offset == num in first check of vm_map_pages_zero()
To: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Huang Ying <ying.huang@intel.com>, 
	open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 1:38 AM Miguel Ojeda
<miguel.ojeda.sandonis@gmail.com> wrote:
>
> If the user asks us for offset == num, we should already fail in the
> first check, i.e. the one testing for offsets beyond the object.
>
> At the moment, we are failing on the second test anyway,
> since count cannot be 0. Still, to agree with the comment of the first
> test, we should first there.

I think, we need to cc linux-mm.
>
> Signed-off-by: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd0c317..74cf8b0ce353 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1547,7 +1547,7 @@ static int __vm_map_pages(struct vm_area_struct *vma, struct page **pages,
>         int ret, i;
>
>         /* Fail if the user requested offset is beyond the end of the object */
> -       if (offset > num)
> +       if (offset >= num)
>                 return -ENXIO;
>
>         /* Fail if the user requested size exceeds available object size */
> --
> 2.17.1
>

