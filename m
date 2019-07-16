Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3D41C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E52D2145D
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M1ei1CGt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E52D2145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72476B0003; Tue, 16 Jul 2019 06:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E258B6B0005; Tue, 16 Jul 2019 06:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CECBF8E0001; Tue, 16 Jul 2019 06:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 983886B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:28:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so9964105pla.3
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 03:28:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Y9oHIuUnvA5xAOt2sG5I7PMnR70HX2a42btCOmZ0knc=;
        b=YopSBwOxUAU9oaVz8OGxizko60hK0b+Fih6QXtEHMHaHP072tKBOlF0pbn+p+OfUKU
         fO0T1DExMGz2AJn7dQtQBeqqR3e3CeIHQwON+tT0TOACZkHyi00QeKqyu/ey8I2vCLU7
         a1rZ/Yau3UHL2vojosROkS3G9Ic+kK5cLQFV1C+PKcPIfGywsjGwuvzm5BthILXyOjdm
         c7/Zb4LMjUqfr7WzEvKBHGLUOZ1kMh4NRAcAO/0XejAE/Wqh3GVCq5vd+fZQnLhYfCHb
         ikGeRjvXOQeSJ/1PY7XF2gfzcb8GKnl25LhYCu/1LPsV0ttzPch4PdwkSo7I5QLP8eSe
         Ntig==
X-Gm-Message-State: APjAAAU+akynHL0ZDox/habxE1nt0JtT3k6eqPAceqLa1dMQGE+AKBve
	Gsexkt1Xsk6XQzBDYHcSMro6CYVJXkF88cXjtGhhZjWheA+qdM3/eHkmmBOYnXDfHfgWgav9h1X
	CFiAwuuZ22TjLk14zP5pYHJClLtLp3D95ZS+BKp2nwL6pntNQ9NzBlBNwKJWvuaCfhg==
X-Received: by 2002:a65:44cc:: with SMTP id g12mr20704077pgs.409.1563272905074;
        Tue, 16 Jul 2019 03:28:25 -0700 (PDT)
X-Received: by 2002:a65:44cc:: with SMTP id g12mr20704006pgs.409.1563272904120;
        Tue, 16 Jul 2019 03:28:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563272904; cv=none;
        d=google.com; s=arc-20160816;
        b=tT93L7A6Q87FzCfUlMpxhrxLhRmDgBCCdzBaK5aykgYZZfb+t36uWEeqKUzRu8mLfK
         vKwSKbU8le6uTQTj0QZYKqvnsVRi8ZO+jNCtNZYhjX9tBmmzS2w2HpFtZAOI1xgE3qJ0
         nnq/i5gCyapx0Xa3l3LKsDM0IZmPaK1dZmLbOjkf3MG7+0Jcy5pqKnjC3ZwI4bx5rOLa
         TIuewigZa0Pi1TkhGn3+zppygMwURIC38QGlO95tiCHufufV2TIvthgEo/cv0n9ITwXs
         J7tBkkVuLagPXUab2nqjnq6PtGweGYlarAAKsV0N72MGvUQ6dwCB2/NsRSrDfV/Bh8Ow
         amrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y9oHIuUnvA5xAOt2sG5I7PMnR70HX2a42btCOmZ0knc=;
        b=wxnSlJeoZvcptMgcnv10WgVPIBI5skjmDAAqo6JM+uzsSzCh0u+Z+p9VfRFrYCIU8Q
         mBi9UEdV1m5biZtftHSgo0W6nCzcieGh+6D/5R06szHruinHc4w25zvpaqQaQ16pYBRf
         Eus8jNRtgJvM4fDMFIcKSxkCsHC48jdCY75qmF4W0BGlKYnWWQAgkeYOIMH/4n3Vbil3
         yqI+gCvtXR0WyI5DxJLsqsNAXMGKqjCMNjuxYze7EWdYOzpqfx6SFDxmflJp2O9jkJo6
         8NzjetRloaVe43DqPq12b+yAocl/RLdr/kBPCINbMs8cJFjTTc3FWcwgTRZiJMXe5xpL
         M/JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M1ei1CGt;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor10634909pfr.48.2019.07.16.03.28.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 03:28:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M1ei1CGt;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Y9oHIuUnvA5xAOt2sG5I7PMnR70HX2a42btCOmZ0knc=;
        b=M1ei1CGtQUJ5wTz3qfdFMu+ibfhjsSqHNuABQXK+2mW2UaYsiKQmVgHImwaupyK1SJ
         WUzRu+v5p7JsCmFBucUUvbohrtTGD97XSBRI1dYMytdItzK17BNlRGMrQA+h/ELLHQzR
         LcE41K2Ds0I3L3RXd98KR7nMiZM5xKj7ndtMxKrcP1qX3ePptWLdDV5OTMPXyB0+JtMw
         Cm18CJIz9Z36j842xjw/5DYVtYdMGcg49LjUOFevHhJuhtJBtgUmsfxOJ7eJ7+mCIqIH
         DsxwZZcDk5a35gmc2Q+XPfARfNueBwJWzGiKzPi7CoLDdEWoaNtwPS7kePJcxf00Wcuc
         8yZA==
X-Google-Smtp-Source: APXvYqzOWjwHADtg0IeTrZRs0dD/whTFszTRqY/XHlwCOHIyoUAXjjxmcFPlmNZSWKUocUa8VGy4Bw==
X-Received: by 2002:a63:494d:: with SMTP id y13mr33092205pgk.109.1563272903599;
        Tue, 16 Jul 2019 03:28:23 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id p27sm33040074pfq.136.2019.07.16.03.28.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 03:28:23 -0700 (PDT)
Date: Tue, 16 Jul 2019 15:58:14 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Matt Sickler <Matt.Sickler@daktronics.com>,
	"ira.weiny@intel.com" <ira.weiny@intel.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jglisse@redhat.com" <jglisse@redhat.com>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
Message-ID: <20190716102814.GA8715@bharath12345-Inspiron-5559>
References: <20190715195248.GA22495@bharath12345-Inspiron-5559>
 <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
 <SN6PR02MB4016687B605E3D97D699956EEECF0@SN6PR02MB4016.namprd02.prod.outlook.com>
 <82441723-f30e-5811-ab1c-dd9a4993d7df@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82441723-f30e-5811-ab1c-dd9a4993d7df@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 03:01:43PM -0700, John Hubbard wrote:
> On 7/15/19 2:47 PM, Matt Sickler wrote:
> > It looks like Outlook is going to absolutely trash this email.  Hopefully it comes through okay.
> > 
> ...
> >>
> >> Because this is a common pattern, and because the code here doesn't likely
> >> need to set page dirty before the dma_unmap_sg call, I think the following
> >> would be better (it's untested), instead of the above diff hunk:
> >>
> >> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c
> >> b/drivers/staging/kpc2000/kpc_dma/fileops.c
> >> index 48ca88bc6b0b..d486f9866449 100644
> >> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> >> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> >> @@ -211,16 +211,13 @@ void  transfer_complete_cb(struct aio_cb_data
> >> *acd, size_t xfr_count, u32 flags)
> >>        BUG_ON(acd->ldev == NULL);
> >>        BUG_ON(acd->ldev->pldev == NULL);
> >>
> >> -       for (i = 0 ; i < acd->page_count ; i++) {
> >> -               if (!PageReserved(acd->user_pages[i])) {
> >> -                       set_page_dirty(acd->user_pages[i]);
> >> -               }
> >> -       }
> >> -
> >>        dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> >>
> >>        for (i = 0 ; i < acd->page_count ; i++) {
> >> -               put_page(acd->user_pages[i]);
> >> +               if (!PageReserved(acd->user_pages[i])) {
> >> +                       put_user_pages_dirty(&acd->user_pages[i], 1);
> >> +               else
> >> +                       put_user_page(acd->user_pages[i]);
> >>        }
> >>
> >>        sg_free_table(&acd->sgt);
> > 
> > I don't think I ever really knew the right way to do this. 
> > 
> > The changes Bharath suggested look okay to me.  I'm not sure about the check for PageReserved(), though.  At first glance it appears to be equivalent to what was there before, but maybe I should learn what that Reserved page flag really means.
> > From [1], the only comment that seems applicable is
> > * - MMIO/DMA pages. Some architectures don't allow to ioremap pages that are
> >  *   not marked PG_reserved (as they might be in use by somebody else who does
> >  *   not respect the caching strategy).
> > 
> > These pages should be coming from anonymous (RAM, not file backed) memory in userspace.  Sometimes it comes from hugepage backed memory, though I don't think that makes a difference.  I should note that transfer_complete_cb handles both RAM to device and device to RAM DMAs, if that matters.
Yes. file_operations->read passes a userspace buffer which AFAIK is
anonymous memory.
> > [1] https://elixir.bootlin.com/linux/v5.2/source/include/linux/page-flags.h#L17
> > 
> 
> I agree: the PageReserved check looks unnecessary here, from my outside-the-kpc_2000-team
> perspective, anyway. Assuming that your analysis above is correct, you could collapse that
> whole think into just:
Since the file_operations->read passes a userspace buffer, I doubt that
the pages of the userspace buffer will be reserved.
> @@ -211,17 +209,8 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
>         BUG_ON(acd->ldev == NULL);
>         BUG_ON(acd->ldev->pldev == NULL);
>  
> -       for (i = 0 ; i < acd->page_count ; i++) {
> -               if (!PageReserved(acd->user_pages[i])) {
> -                       set_page_dirty(acd->user_pages[i]);
> -               }
> -       }
> -
>         dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> -
> -       for (i = 0 ; i < acd->page_count ; i++) {
> -               put_page(acd->user_pages[i]);
> -       }
> +       put_user_pages_dirty(&acd->user_pages[i], acd->page_count);
>  
>         sg_free_table(&acd->sgt);
>  
> (Also, Matt, I failed to Cc: you on a semi-related cleanup that I just sent out for this
> driver, as long as I have your attention:
> 
>    https://lore.kernel.org/r/20190715212123.432-1-jhubbard@nvidia.com
> )
Matt will you be willing to pick this up for testing or do you want a
different patch?
> thanks,
> -- 
> John Hubbard
> NVIDIA
Thank you
Bharath

