Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCC15C43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A032420838
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="GOMgzAf/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A032420838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F186B0006; Fri,  6 Sep 2019 11:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 418326B000D; Fri,  6 Sep 2019 11:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DE976B000E; Fri,  6 Sep 2019 11:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 078736B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:44:23 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A9973181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:44:23 +0000 (UTC)
X-FDA: 75904917606.17.badge53_607dfa7e47520
X-HE-Tag: badge53_607dfa7e47520
X-Filterd-Recvd-Size: 4457
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:44:22 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id c19so6655424edy.10
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 08:44:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UXzffckHlrDd2GxMkcUegpxPLxQbezYI5SKZXnOnJzk=;
        b=GOMgzAf/lkF5c2eKwXgjCw9a3KXnWR5APRE7h0mk6NdXu79AGiO8sODfHid9N6Xl5h
         M/C8KT/SLLU5H1Aqg4nwEKOuTu5OkbyrUQJTErU8uVcm673iUBJEH32XMXPStUacK9QI
         xCMSuQrJe1j8CHQBTWz9PB+Jomp1+g+QD9Tkd9KMYHmJWFzG5xyCzw8xyfNgbLXZwkrs
         5FlS9o5FS4p8okYBPzuG2ITgzJGemxFxUkm3aSbDG/x0MDmUmazIm6dOMXX9j66GMFk+
         3cLHZkaYpm/muQI+jLdcObCu1m/ydijbn1wGNoRDjuAv/Fx5CRGdTNnFLVIVNVPLSSN2
         qWrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=UXzffckHlrDd2GxMkcUegpxPLxQbezYI5SKZXnOnJzk=;
        b=SONXlruBz/oaBx/RLuDWcoQxG9+GJRDg03NUIvwShqtDO4ZOG0hxB54oIPpdrj2fHR
         eZLzg36Bpbi5m63m8ilR2yZFnwi4Sly78zXzc6eZep34GzM226K3XQeM4wOqBlu2IScd
         y9WtjZlJs7mZ9r/PW7rbsMXNybqQTBbPtfdZ5qRZuHiy1AXSOo6SAm0yqItDm2bo+X0P
         D32s9E14Kz1HRS2gquSPEiEbUfISIhKCcgjzNeUkwBiwHqxBG8jUCP0Qq8rTZXL9kXXO
         EciUBVq57Omvnpk0teHVPyFgbgtPB5CyZeO2Xi6MhCycr6t0iHHv3Qy0hXzzkAc88tmY
         c2gg==
X-Gm-Message-State: APjAAAWvLrlqCx3xdd7G7CjYiIzNxqdMp/UBZdui6REuD/9U6UgChwe4
	1HvUU4ZPQiBVNNcHnLcbVBzxpN+1krjPmHoCZmahCw==
X-Google-Smtp-Source: APXvYqwplMA0AW8lXkCWQuG9K8cCsGpwcuOwcj3r1h53xYTkZkNhYGGnMNAxboAR+e2euONipoiDRfZvyN8jJZQFWsM=
X-Received: by 2002:a17:906:f04:: with SMTP id z4mr8127839eji.209.1567784661783;
 Fri, 06 Sep 2019 08:44:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
 <20190821183204.23576-6-pasha.tatashin@soleen.com> <ddd81093-89fc-5146-0b33-ad3bd9a1c10c@arm.com>
In-Reply-To: <ddd81093-89fc-5146-0b33-ad3bd9a1c10c@arm.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 6 Sep 2019 11:44:10 -0400
Message-ID: <CA+CK2bBXfa0MFspOpWAGL4Q7iYH9UMdKAwMD-PyL7Wp4s64x+Q@mail.gmail.com>
Subject: Re: [PATCH v3 05/17] arm64, hibernate: check pgd table allocation
To: James Morse <james.morse@arm.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Vladimir Murzin <vladimir.murzin@arm.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 11:17 AM James Morse <james.morse@arm.com> wrote:
>
> Hi Pavel,
>
> On 21/08/2019 19:31, Pavel Tatashin wrote:
> > There is a bug in create_safe_exec_page(), when page table is allocated
> > it is not checked that table is allocated successfully:
> >
> > But it is dereferenced in: pgd_none(READ_ONCE(*pgdp)).
>
> If there is a bug, it shouldn't be fixed part way through a series. This makes it
> difficult to backport the fix.
>
> Please split this out as an independent patch with a 'Fixes:' tag for the commit that
> introduced the bug.
>
>
> > Another issue,
>
> So this patch does two things? That is rarely a good idea. Again, this makes it difficult
> to backport the fix.
>
>
> > is that phys_to_ttbr() uses an offset in page table instead
> > of pgd directly.
>
> If you were going to reuse this, that would be a bug. But because the only page that is
> being mapped, is mapped to PAGE_SIZE, all the top bits will be 0. The offset calls are
> boiler-plate. It doesn't look intentional, but its harmless.

Yes, it is harmless otherwise the code would not work. But it is
confusing to read, and looks broken. I will separate this change as
two patches as you suggested.

Thank you,
Pasha

