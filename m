Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3EEDC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73C7620663
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 00:20:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P3G+XDC9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73C7620663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 103346B0003; Wed, 26 Jun 2019 20:20:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B4468E0003; Wed, 26 Jun 2019 20:20:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0A668E0002; Wed, 26 Jun 2019 20:20:20 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D1A296B0003
	for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 20:20:20 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id j18so540517ioj.4
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 17:20:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=J0fxw6N73maQ02G9biYfnSH2j9AnglVamO/dzWb0ntQ=;
        b=QC99NGnopbhO090oB8KSmgNiUATrz7MlJG5j8cTgUkTqZOktvkKI99sanRUSHlZ/uS
         RnY1jZTq1Xrw5d6KJuNBPkf7WEhGqReH/C+xvf4sQ9eqqVgqRkBeXuGAicG1X3Kal+6l
         0z6f3ky/4aaGL59SfsHQRjhvi5KriDcFP/g5aNGFV1bzFX0qx8WXxxWSO1bz9e1qO0Me
         hRnComr/1F2dL1J6adjb8aK+3mwDSJWs92Lj40F/pxWH+nmWtDxg+vmNa2HvdBvH7WGa
         LU29Fi0K50hIrLcTA7CKaQAvgqkfEyReGApGLfuFbbM/Z3nW23lfuBVOqk3zsawpIEvB
         pNMQ==
X-Gm-Message-State: APjAAAUISYyueNVkRCbPCxfOfQZeTi14N/tARLiIy/EMQdMMzse7QgFh
	c3NA2sXCwcehbJ8A6PzCiDUucdS5fVgTD2z5oL8C0L2A2hTXKhVp2BxGYSLZbMatM8N4nxUtqrF
	88vZL2UmbXQIChUwGBT54vCEpqlBZEZVujyOgQoO9ItEdpk6ncYA41uAVS8gRm8XJUw==
X-Received: by 2002:a6b:f607:: with SMTP id n7mr1175456ioh.263.1561594820602;
        Wed, 26 Jun 2019 17:20:20 -0700 (PDT)
X-Received: by 2002:a6b:f607:: with SMTP id n7mr1175417ioh.263.1561594820007;
        Wed, 26 Jun 2019 17:20:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561594820; cv=none;
        d=google.com; s=arc-20160816;
        b=jRySSA7QJMkO8XvguC0xOX1Ym50hydjgn1P8i8UaGJhBYZJFy0xUcA6NMlZY9TLx5x
         HDAqVax84cxpOjooAPw9mXq4cMbDtfvtRnx24nYzqYJwzmY6Ec+2lEYCq9eang+0IWcQ
         IhiqqGswoanP1subW2GaEbpV2wGr32a0n9THYEDOjMTHFVQsdJj3qUIWYhmcjZYszsft
         Qm67MyUeWBLCOT31JV22ZAKGCBZVzEjmo3Q+/oLirVsbbbciGRqnVrmvRZ1D0HyYyQS+
         Y3oMTh07TS/beQQCTXFMsW8dKgBmNViccA5QDh9EUOl+q/Uj/zCpxLweY8ZTbogaUHFs
         TEzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=J0fxw6N73maQ02G9biYfnSH2j9AnglVamO/dzWb0ntQ=;
        b=BvFSEvX3TKvXTk4s7nIWFP4DQz6JrsN/8Lk3Xljutb0BA/YEXbR1YHQdNHzkUwjbDR
         ozgfcpPDtq1dZ/0rBQbk+T86NATlPjtnLNzTFlcWfdHL/2hBibjPGF1BkG/+mif00mAo
         LTX8Z/f/8skc/aCdYGodcEy2v6EIA8abgtxjg9Y0O4Q9alSi5dz2pHllzRGYWmD6z7n1
         A6FxYAv97jQY8j4xtSZfuHvSAjlXC628ACCtuzvevS7A0dr4ZpsTR3mB2+L9gb7Uuc7b
         nss4lM8NBM1ObnW+ZSvGcAD/z9uCT/Eg2fDXv/AvkKnGCJsM3bPrQPDWvgHY7uaesYlV
         1LzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P3G+XDC9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor345023ioj.24.2019.06.26.17.20.19
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 17:20:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=P3G+XDC9;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=J0fxw6N73maQ02G9biYfnSH2j9AnglVamO/dzWb0ntQ=;
        b=P3G+XDC9VgTBzI6prnBC/uoupIscWeaFkykn0frPLnMoX27cY2wFBV4KE7fIl3B+5J
         0Fvi+As/bWtZj6GcKHwonh2Z/Gor1tPnxU6kd00O5xdUATX/7HvAI+TVp/lbRJUmGhBk
         vKmKNwNm9oLF9QFkwzhC/uTg8G6BG5naJs+h6NSi9EQCdelKoxb4dkW1luyMdMDL/eeU
         TqGCAZVJw8jRExmpDzTalZhG9hyKFvPVn9+MPtVAphy7aWsuBc50dlugLXzefc5TrD8C
         8h9it1TEvX7GNchKEq+QDfj/IT9DTWPDC7HvV36wmOD4SOTQRBRuW1Wneijl89RM0HzN
         n6DQ==
X-Google-Smtp-Source: APXvYqzZUD3KYaX5KnFZWHBBrVKwteLRfw/EGBDdzcHQz8rb2VLtjI8X4yhzXDL2yWbtb851BY9X/DPvVjlSOBVxMIg=
X-Received: by 2002:a6b:6f06:: with SMTP id k6mr1220728ioc.32.1561594819720;
 Wed, 26 Jun 2019 17:20:19 -0700 (PDT)
MIME-Version: 1.0
References: <1561554600-5274-1-git-send-email-kernelfans@gmail.com> <20190626161537.ae9fcca4f727c12b2a44b471@linux-foundation.org>
In-Reply-To: <20190626161537.ae9fcca4f727c12b2a44b471@linux-foundation.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 27 Jun 2019 08:20:07 +0800
Message-ID: <CAFgQCTubW0GsYmJUfitd=B_a0JhiyFXHXx9sGzq-AWDP2hg+nA@mail.gmail.com>
Subject: Re: [PATCHv4] mm/gup: speed up check_and_migrate_cma_pages() on huge page
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Thomas Gleixner <tglx@linutronix.de>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, 
	Keith Busch <keith.busch@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	LKML <Linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 7:15 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 26 Jun 2019 21:10:00 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:
>
> > Both hugetlb and thp locate on the same migration type of pageblock, since
> > they are allocated from a free_list[]. Based on this fact, it is enough to
> > check on a single subpage to decide the migration type of the whole huge
> > page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> > similar on other archs.
> >
> > Furthermore, when executing isolate_huge_page(), it avoid taking global
> > hugetlb_lock many times, and meanless remove/add to the local link list
> > cma_page_list.
> >
> > ...
> >
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> >       LIST_HEAD(cma_page_list);
> >
> >  check_again:
> > -     for (i = 0; i < nr_pages; i++) {
> > +     for (i = 0; i < nr_pages;) {
> > +
> > +             struct page *head = compound_head(pages[i]);
> > +             long step = 1;
> > +
> > +             if (PageCompound(head))
>
> I suspect this would work correctly if the PageCompound test was simply
> removed.  Not that I'm really suggesting that it be removed - dunno.
Yes, you are right. compound_order() can safely run on normal page,
which means we can drop the check PageCompound().

>
> > +                     step = (1 << compound_order(head)) - (pages[i] - head);
>
> I don't understand this statement.  Why does the position of this page
> in the pages[] array affect anything?  There's an assumption about the
> contents of the skipped pages, I assume.
Because gup may start from a tail page.
>
> Could we please get a comment in here whcih fully explains the logic
> and any assumptions?
Sure, I will.

Thanks,
  Pingfan
>

