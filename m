Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F024FC76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 20:52:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E5FD2086C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 20:52:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vRaErLWa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E5FD2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8A26B0003; Mon, 15 Jul 2019 16:52:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8A8E6B0005; Mon, 15 Jul 2019 16:52:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D79B76B0006; Mon, 15 Jul 2019 16:52:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A24016B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 16:52:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i26so10897099pfo.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 13:52:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kR4xbKeLkqzM5m4IkfGOvFM7+dvSxhNFEJ7oNVJrvqQ=;
        b=ji0Q5FauCWJVtXpYc5Yxx3BSXt685WrkS9xbdbmSFyDbYZf9WpWbYGjWbDpZV5dWmL
         vhnrkDItZjvaxDC2e/NPlwgCb2Ssdxz/QAYmSZktSI6gVaxMNt+Wz1Qb1+Hu8aai2euI
         IdLcdjD45jCvuLfAzPni8PJy28oex0gls0J/3n63VKfew6gv1RQQCl8ygPrXJCcRgyQC
         kFKOF5e1hmqEdQVXpCERMg2ViOGbTysUHlWO/t3Tfs0nTgAbmQmRwlPVcQNgFnSV5t80
         q4OjXzWKgHbfcWOoC3WFEwwU32F/ebAauCPSRzNrA6d0ky6uSHo8pZ/rWxyvS3aDGV7k
         9fIQ==
X-Gm-Message-State: APjAAAXQRvTBopy/fDjkj6LZ1eq5pdPoWpZ7a8YGJiZS6V/aMIiHw9ga
	hfGNF1GyOUVYhiGP7/eL8JKZCDnAlKbE6JKMbr/PL9cQuyKvtAeTS0T9tv8MAKeNZzEi1zkby//
	X/tq6pN4zUGQBGXw3/kAmH4h81Gg9KP1Ta+IbBCjwmz0RSPjB1ttFKnhPqNHs8R0UQQ==
X-Received: by 2002:a17:90a:37ac:: with SMTP id v41mr30072864pjb.6.1563223947188;
        Mon, 15 Jul 2019 13:52:27 -0700 (PDT)
X-Received: by 2002:a17:90a:37ac:: with SMTP id v41mr30072790pjb.6.1563223946217;
        Mon, 15 Jul 2019 13:52:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563223946; cv=none;
        d=google.com; s=arc-20160816;
        b=bWAbX9ldFUGQ0h3cvTd1di8R80lbYoyfSuPZ1q6ZSDGcpFzcp0dVz+5Wx3YlmZaczc
         Kjw6uWInPd2YeA9Ny/twYP1u5E1KEa8Iwuwpg30/Cjy99ty/Pavcd0+923jCqvjgcCTo
         ksPTyv2awefUb/R1LegThiA/WPt/Soy8ZE7PUkhOV37M6VxUI98RxiFOaSNRI2g7Vn8v
         P48TlMZ/IONiHrRO5ExrtvNzO0SHsroiBHsIaqMMidnn02woBF81YRmLdrodQ5AOT9Cy
         quEVZTzpkTWz7rLApB0o8vXqRyxAj3qumIBq5BjvvX/HeC0PuRF/tj9+lat7I1bhNl8s
         6K2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=kR4xbKeLkqzM5m4IkfGOvFM7+dvSxhNFEJ7oNVJrvqQ=;
        b=znGitFOS1G0CiiDF+gr443dGZL7SsGu3sVEOpTfy2EiHDPOeY+bWueK5An/4Ra6ZyR
         btYeot9sNUOLYLBIJuuy84yMzIKjSLnmO4LFMZIWMB4YejIAKS9BSSVFz7YPcrhl3/hy
         EHDGoKd/Ma001iRqyjJKq79TlwUARud7cZyUIwontHuQAr/OEDKJYxwuO2P2eEE1ekCL
         ATnlIX91HbquRD3YEL9kTPpmjqvd742e1uigDuoZIRMC545jktThUiAUvjwf8uCoTG8o
         PFAsJMhIvboeheBmOSvQGVCFTDlu5qmAGM80AcC2ITsCx/z1m37sdIfpLVpMwhwx7m64
         iqvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vRaErLWa;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor22352783pls.29.2019.07.15.13.52.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 13:52:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vRaErLWa;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=kR4xbKeLkqzM5m4IkfGOvFM7+dvSxhNFEJ7oNVJrvqQ=;
        b=vRaErLWauN0PK2S1rhodMt5sJ3WgJaXgnY2tZZxt8XarHR9jtlCcHgwbau1887Ce6V
         wPwnxhzyeoa24uBZQy/lPcYwOxNYpnCjVZOAYrzllp8Jyldk5UMiNAkuK/5gILgpL7zT
         I/+OhYEkG4eAPKGLBzTMxMuui60/CxzsYA7S+G0SNSSHgkuqThYPYFSErYnVpHXbHOzs
         96nqyqsVFaFugyW+U8nFSigdHjuizyEtOxUb+POScUYS3z3JezDsjI6snDDWhsHxK8Bx
         GtaT0Zy5clHx4yrkJBeaMpdOrIW6qz1NzJ+5xML90nBEkDt+FTMB1wts3Bf9xRU/tdHX
         b0hw==
X-Google-Smtp-Source: APXvYqxEa3WgGh3U0Jn4/Smo82YSRjT7yS9UoqfVPVb6FVIPqlesr9mgxDqSMQvxauH1zQPJ8wmqLA==
X-Received: by 2002:a17:902:4c88:: with SMTP id b8mr31598648ple.29.1563223945760;
        Mon, 15 Jul 2019 13:52:25 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id 185sm22172155pfa.170.2019.07.15.13.52.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 13:52:25 -0700 (PDT)
Date: Tue, 16 Jul 2019 02:22:16 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: ira.weiny@intel.com, gregkh@linuxfoundation.org,
	Matt.Sickler@daktronics.com, jglisse@redhat.com,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
Message-ID: <20190715205216.GD21161@bharath12345-Inspiron-5559>
References: <20190715195248.GA22495@bharath12345-Inspiron-5559>
 <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 01:14:13PM -0700, John Hubbard wrote:
> On 7/15/19 12:52 PM, Bharath Vedartham wrote:
> > There have been issues with get_user_pages and filesystem writeback.
> > The issues are better described in [1].
> > 
> > The solution being proposed wants to keep track of gup_pinned pages which will allow to take furthur steps to coordinate between subsystems using gup.
> > 
> > put_user_page() simply calls put_page inside for now. But the implementation will change once all call sites of put_page() are converted.
> > 
> > I currently do not have the driver to test. Could I have some suggestions to test this code? The solution is currently implemented in [2] and
> > it would be great if we could apply the patch on top of [2] and run some tests to check if any regressions occur.
> 
> Hi Bharath,
> 
> Process point: the above paragraph, and other meta-questions (about the patch, rather than part of the patch) should be placed either after the "---", or in a cover letter (git-send-email --cover-letter). That way, the patch itself is in a commit-able state.
> 
> One more below:
Will fix that in the next version. 
> > 
> > [1] https://lwn.net/Articles/753027/
> > [2] https://github.com/johnhubbard/linux/tree/gup_dma_core
> > 
> > Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: linux-mm@kvack.org
> > Cc: devel@driverdev.osuosl.org
> > 
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> >  drivers/staging/kpc2000/kpc_dma/fileops.c | 8 ++------
> >  1 file changed, 2 insertions(+), 6 deletions(-)
> > 
> > diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > index 6166587..82c70e6 100644
> > --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> > +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> > @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
> >  	sg_free_table(&acd->sgt);
> >   err_dma_map_sg:
> >   err_alloc_sg_table:
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > -	}
> > +	put_user_pages(acd->user_pages, acd->page_count);
> >   err_get_user_pages:
> >  	kfree(acd->user_pages);
> >   err_alloc_userpages:
> > @@ -229,9 +227,7 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
> >  	
> >  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> >  	
> > -	for (i = 0 ; i < acd->page_count ; i++){
> > -		put_page(acd->user_pages[i]);
> > -	}
> > +	put_user_pages(acd->user_pages, acd->page_count);
> >  	
> >  	sg_free_table(&acd->sgt);
> >  	
> > 
> 
> Because this is a common pattern, and because the code here doesn't likely need to set page dirty before the dma_unmap_sg call, I think the following would be better (it's untested), instead of the above diff hunk:
>
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> index 48ca88bc6b0b..d486f9866449 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -211,16 +211,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
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
>  
>         for (i = 0 ; i < acd->page_count ; i++) {
> -               put_page(acd->user_pages[i]);
> +               if (!PageReserved(acd->user_pages[i])) {
> +                       put_user_pages_dirty(&acd->user_pages[i], 1);
> +               else
> +                       put_user_page(acd->user_pages[i]);
>         }
>  
>         sg_free_table(&acd->sgt);
I had my doubts on this. This definitley needs to be looked at by the
driver author. 
> Assuming that you make those two changes, you can add:
> 
>     Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Great!
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

