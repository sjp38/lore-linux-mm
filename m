Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CD1EC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E6C2206C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 14:03:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="HEjJDRLT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E6C2206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA6E66B000C; Fri,  7 Jun 2019 10:03:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57AE6B000E; Fri,  7 Jun 2019 10:03:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 945856B0266; Fri,  7 Jun 2019 10:03:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 740336B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 10:03:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id s9so1901408qtn.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 07:03:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=P7GoCE6Vzl1X5NohwcLhAV/U9MsA/FhXn4++zB5+WQw=;
        b=Q1lnYTRQmEgV4Nwh3j/ptrRvVyqR/i2zoQ7unqSDt/5AUW2Y0rIwIqm6NJ4LS0FpdB
         /1DfCIfPFY3UsWmHWpbZZM6TxSciZ9NIb9pvVjEaf0bJK1WYzLab7OXvwnVy3IJPq1jQ
         z+EPpeCj77S0ofT+HtAgMY9WEWiOX72xNJk9Zv8X91b31tpxIL1eS9R7JyHYRhXS1Knz
         VTL9vOGcWeK4A2NbStry0TX6N4rXatdOsdIOg0Fn74d8hQaNuktqLy1HV++vUu6JAAYk
         +zQDY38zOF2uX4VMHQ67oPw0vI5EQ7xu5MigVKUb0pZPT/OZiZwf5ixpRexpxwbRVtAT
         hXgg==
X-Gm-Message-State: APjAAAWvO68q8FLJJEdEmRG/rMCR0DJB4kmf42HgZZ6LfZ++IaQarsia
	17gMKip9WMbBgSaBVLN7kL88xAuZpCYDkeDtaWu/xzdJtzjKEWsvWUvqe6QZpNdt19KSLltsQ3z
	4cbhUL2lSE1vxOOcFugou5ovg/3yBEkPj/+8Xv4yBSlwT7Xj0P5tKSBgYTdcyp/87+A==
X-Received: by 2002:a0c:8af0:: with SMTP id 45mr21938032qvw.111.1559916196227;
        Fri, 07 Jun 2019 07:03:16 -0700 (PDT)
X-Received: by 2002:a0c:8af0:: with SMTP id 45mr21937975qvw.111.1559916195669;
        Fri, 07 Jun 2019 07:03:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559916195; cv=none;
        d=google.com; s=arc-20160816;
        b=C8GhxE/GFTmj/U5ODuv+FhTk65+yv/D77jLLHFxVBIB9ziExX1v30+RIfBfpmGcaKI
         sF7DougF5rbC5i+6YThC/LdArg4anva37xBz0XwF06RE+NMu09DC5tAjGDNteEctkrRb
         2KDK1JH0y5DRjVU9700dJLLwFIxnDPDEjPJ+9YWu5U6f4j7i8aC8kvVMlm2kZ5J4abpV
         3lCbs/+IVdarUCGpjz1jdbmWQ0fPztm8YLq4rimmhlDuXs0LErNnZ7ug82Bug9NHOnF3
         UxuhNNgN1QsQ2Osm6wlYXczIUMca25pw/4e1w9ErJUjQhPrSJRk6xU7EzPsbGf5VeaCO
         RRJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=P7GoCE6Vzl1X5NohwcLhAV/U9MsA/FhXn4++zB5+WQw=;
        b=fStFbWadTdcTaNqT//0Qsz8hjQ/whohPIxhoC4YBgracLrbtMX/abSTP4j/ufmNYIF
         iA+8382jle+hDiDXaxZVm5SxBeMSULEZIxDwVCMRi1CAo7kWZBUCy+rR2jdr9C/z6WpN
         S5RLh+d+NNrZ+4E8rQEAycJu5WXPMItMXH0zt6OeFb7nT59eXQZOdywVDJaMLd49bGK2
         KmzGoFFur8LHWqrubJLcRARQ4TUWSQBR994jeZQk023Gd6tSFCadWnwvtjO5ozoYTVEj
         FKx7PPRXyUwgnroV0SLkxjVLr/S3XeT7kLH1fX0JyO4j5TzG/I1739r8CWS7Sbc5nyQM
         YGmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HEjJDRLT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f14sor2456603qtk.36.2019.06.07.07.03.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 07:03:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=HEjJDRLT;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=P7GoCE6Vzl1X5NohwcLhAV/U9MsA/FhXn4++zB5+WQw=;
        b=HEjJDRLT1/QrA6H/XpWwtPycyetApCN4CInuydPmEmSGPRRJv+Cn/jI64AeZu0N/bC
         PXklr3+VSClv6Qje5a8q/NaHAeR2RO96W4pxfd9tEXkAS8YQuSd8rdwNTzvHpyEhvlzB
         R6bFoF/NlWFv03tX7XWcM8xVuEbzIMN2maEqxblaz42nopqucXcsniwmuN3bycCbynMh
         +mIYN90GQZsDgAFyAZaFZK4r64NsWLjFXc9zviD8/t0b3KHPgkMMdG5HQuqfhvA8fR/p
         GWBn+WTOku/tkXz7yhlu+QqUseN0G5TjKCGMeF2EOBa1naQKJUB7b4ZX8y76Hd3jGLEM
         PHaQ==
X-Google-Smtp-Source: APXvYqz2/915uO4AoJkylfCxPwtwvf01ilYy48xf4ydSxLalVse+hWheTEibI1VzArzBO6/jyTi2Rg==
X-Received: by 2002:ac8:7342:: with SMTP id q2mr5402914qtp.134.1559916195107;
        Fri, 07 Jun 2019 07:03:15 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id d123sm1160617qkb.94.2019.06.07.07.03.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 07:03:13 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hZFSb-0003fn-4v; Fri, 07 Jun 2019 11:03:13 -0300
Date: Fri, 7 Jun 2019 11:03:13 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
Message-ID: <20190607140313.GI14802@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-10-jgg@ziepe.ca>
 <c00da0f2-b4b8-813b-0441-a50d4de9d8be@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c00da0f2-b4b8-813b-0441-a50d4de9d8be@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 08:37:42PM -0700, John Hubbard wrote:
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
> > and poison bytes to detect this condition.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > v2
> > - Keep range start/end valid after unregistration (Jerome)
> >  mm/hmm.c | 7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 6802de7080d172..c2fecb3ecb11e1 100644
> > +++ b/mm/hmm.c
> > @@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
> >  	struct hmm *hmm = range->hmm;
> >  
> >  	/* Sanity check this really should not happen. */
> 
> That comment can also be deleted, as it has the same meaning as
> the WARN_ON() that you just added.
> 
> > -	if (hmm == NULL || range->end <= range->start)
> > +	if (WARN_ON(range->end <= range->start))
> >  		return;
> >  
> >  	mutex_lock(&hmm->lock);
> > @@ -948,7 +948,10 @@ void hmm_range_unregister(struct hmm_range *range)
> >  	range->valid = false;
> >  	mmput(hmm->mm);
> >  	hmm_put(hmm);
> > -	range->hmm = NULL;
> > +
> > +	/* The range is now invalid, leave it poisoned. */
> 
> To be precise, we are poisoning the range's back pointer to it's
> owning hmm instance.  Maybe this is clearer:
> 
> 	/*
> 	 * The range is now invalid, so poison it's hmm pointer. 
> 	 * Leave other range-> fields in place, for the caller's use.
> 	 */
> 
> ...or something like that?
> 
> > +	range->valid = false;
> > +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
> >  }
> >  EXPORT_SYMBOL(hmm_range_unregister);
> >  
> > 
> 
> The above are very minor documentation points, so:
> 
>     Reviewed-by: John Hubbard <jhubbard@nvidia.com>

done thanks

Jason

