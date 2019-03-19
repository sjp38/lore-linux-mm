Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 257C5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:30:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D68052064A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:30:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EbnszMfP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D68052064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 539426B0005; Tue, 19 Mar 2019 12:30:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C426B0006; Tue, 19 Mar 2019 12:30:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FFAC6B0007; Tue, 19 Mar 2019 12:30:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9416B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:30:11 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x12so20345168qtk.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:30:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=K7tmAcIZjGgQnmSKCgA5OXEhrk3ZonhYzzWN+JLe47A=;
        b=I6x+DheTDpJ+A4t8dsTynp26nHtMhd4fxFxdDSXAhgCmLCICdrWjPHRN0gKoo6K0Vj
         mLk5lD9+iGk0Ok/UExh3F9Q0SVKw7skQ2BH2PM5ADVqsSdKGiAuws1olhKWroTTxHV2K
         uh4MnoT1WrPn7UzNUQIsaF990tMkoY7Ipdni1MoS3EtRQaHanZtjg+TFSLSoHH+ZlQkk
         SARgFKv8cVaJ+JUJBPpcd8Gz5y+jXiKsvzjBYPmkYDECL/AS+xqFWYd+0XBtXw2sMD2Y
         PVuujYr8hewGR2rVPWe+IQ5e9ApSO32SuCxgXgsOiE3TPbJa2Dtvr0KpWRNkjFtXJy9e
         LtEA==
X-Gm-Message-State: APjAAAWxBZHZQKWYlH1brlOxFq2TUpgBm7jK7XEX9oVBBBUIwFawUeSG
	AHZWIfU5KWbnvfezW9laSftKxPqMtBFEQXS8yP/5B+VKhmsjXusCLMOTGUKA98LR8ozOBgXC6e0
	pii2nAN/Fj52Y+gFa9LPHs2zGdaHE5vLqdpFKkj84/1t1VIjxwifwKT+KZFWUKIxFbQ==
X-Received: by 2002:a37:5c84:: with SMTP id q126mr2683427qkb.55.1553013010890;
        Tue, 19 Mar 2019 09:30:10 -0700 (PDT)
X-Received: by 2002:a37:5c84:: with SMTP id q126mr2683385qkb.55.1553013010214;
        Tue, 19 Mar 2019 09:30:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553013010; cv=none;
        d=google.com; s=arc-20160816;
        b=DHRfKT2l55TCSZXTmIJmY7LcOYQFwNWGF3F99CCWCocvB28hIv553n+J6i4aKG/79r
         bjCtJY2zgO7HEmzjCCuvmw6zJgr3ybjgySjoi5vOifXqw8OeKbBuVikagQXe0nU/gxeh
         f/7Lz7jNEOMXpZjOvNrgEQKxNFgzw2zJm96albVQvGUvx2jiiirZmd12Cer5WOyVmQUc
         Q8Aj7IOwDLIKhpT5dHLwNqSxvlrumsjVlm8GU1yglK3a5o1ZC5ArFM7raYvx6J2c1z+F
         hfDf+0LNDZM7SZgP0zWM/C+qn4SEcuPh7usREKcYo7hIFwYREpHYpvEtF2LG0fVO5cC8
         IQ+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=K7tmAcIZjGgQnmSKCgA5OXEhrk3ZonhYzzWN+JLe47A=;
        b=IWiUysWEtpxM/ctgISS/wjZ+qinm5L2eaT5ebsRzWrQRveyeu/oatvmG6JUwHxNYFP
         It6YtIcqocIjfpL/nSsHq9NnyWqJwAhiGDrrP0SXPIx6ClUdxSUE6DkXW/FvnFXWsbC4
         G7OgzZ5wYdQU700PcmTG2qeDOPWQRotjYT1RjHGavtrF140DbWSNJwkwYfvKfD6PMFuo
         96+JdKR29xJOW8aHhuB9+ObtATo7efzDyKRDg3chGHZVxV7+mR6Wo7h+HEkizZLL/IaB
         CKKu2OuEaxlRtfGL6ZYkmGVa+4yRT514JKVIflzRaGgt94xwGYp9QCrhcDahi1zlX+kL
         zozg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EbnszMfP;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q95sor14462967qvq.34.2019.03.19.09.30.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 09:30:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EbnszMfP;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=K7tmAcIZjGgQnmSKCgA5OXEhrk3ZonhYzzWN+JLe47A=;
        b=EbnszMfP0u+7zxc+Uy2lO7wtQyrdjOKh95twCec5p7jbe1izPgev1KYoZPTKayr4zm
         543yA/qO2TaWf/Eq6I7WXRK5m681f1TrZHsI1jut/l/v7Ol5cA5lwIWGwnHTINEYf94K
         6zPEvU2vW2qbJjeHJDbUR9KeEtSEEQvv6heSb/ACEnxHvRKwCAnxns1KztOPIhPbbUJk
         L9uQAqtSgO83tnUNYQEPE44eXO4LiIVWS2Wmi2Rwwht+AcSbxVRaIxKxAT9ErzewAuvt
         UNH5MzSFDvn7f7EtcStXwmEQPYjbQ+LBN0kh0ZsXb65fP9pztuBUWl/NKxTsGiQAdQm0
         lhNg==
X-Google-Smtp-Source: APXvYqweAmx5o0qh/lOpfImkjI24SG7RjMdzpzxhZsWQPkOjCLrAUEhFTLr4TOkGLHog7XEIGU0O1WC+KB9KPa+82Jk=
X-Received: by 2002:a0c:a485:: with SMTP id x5mr2608358qvx.206.1553013010062;
 Tue, 19 Mar 2019 09:30:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190315160142.GA8921@rei> <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de> <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
 <20190319144130.lidqtrkfl75n2haj@d104.suse.de> <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
 <20190319151050.7ym3kdmhec7bf2ky@d104.suse.de>
In-Reply-To: <20190319151050.7ym3kdmhec7bf2ky@d104.suse.de>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 19 Mar 2019 09:29:57 -0700
Message-ID: <CAHbLzkoS0MZXHzz6d9pX=b=HqSoWimT7hOnnKworc7UGxrQztg@mail.gmail.com>
Subject: Re: mbind() fails to fail with EIO
To: Oscar Salvador <osalvador@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Cyril Hrubis <chrubis@suse.cz>, Linux MM <linux-mm@kvack.org>, 
	linux-api@vger.kernel.org, ltp@lists.linux.it, 
	Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 8:10 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Tue, Mar 19, 2019 at 05:52:33PM +0300, Kirill A. Shutemov wrote:
> > On Tue, Mar 19, 2019 at 03:41:33PM +0100, Oscar Salvador wrote:
> > > On Tue, Mar 19, 2019 at 05:26:39PM +0300, Kirill A. Shutemov wrote:
> > > > That's all sounds reasonable.
> > > >
> > > > We only need to make sure the bug fixed by 77bf45e78050 will not be
> > > > re-introduced.
> > >
> > > I gave it a spin with the below patch.
> > > Your testcase works (so the bug is not re-introduced), and we get -EIO
> > > when running the ltp test [1].
> > > So unless I am missing something, it should be enough.
> >
> > Don't we need to bypass !vma_migratable(vma) check in
> > queue_pages_test_walk() for MPOL_MF_STRICT? I mean user still might want
> > to check if all pages are on the right not even the vma is not migratable.
>
> Yeah, I missed that.
> Then, I guess that we have to put the check into queue_pages_pte_range as well,
> and place it right before migrate_page_add().
> So, if it is not placed in the node and is not migreatable, we return -EIO.

Sorry, I didn't see this reply before I replied Kirill's email
earlier. Yes, I agree, it should return -EIO too.

Thanks,
Yang

>
> --
> Oscar Salvador
> SUSE L3

