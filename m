Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39091C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:48:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0499921873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:48:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0499921873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91DA16B000A; Wed, 24 Jul 2019 15:48:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CEE06B000C; Wed, 24 Jul 2019 15:48:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BDD38E0002; Wed, 24 Jul 2019 15:48:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 437CB6B000A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:48:58 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b6so22864485wrp.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:48:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7Mw9NbtoiZQZJOpXdyhGv2HIjy5nvJ4CnKHyPITeaDI=;
        b=dQqia9uMxtk68slWFL4sh/98lEObrOGO/9JD8RrnojN/qvPeS8OkmEidIDs7RQ2Fd/
         vndqEpXqtNLOf9DgAvo27vhchdPQqGbTf5R17/y03kKMknp3lmtL8nMcKrElVBENBAhF
         rBnrsP4nOD0KtatgpgqGXrFj+AuidUM3JaZRy5Q0cahInczJYW/d1twZXxC/wz4NcDCi
         8M27XUyZuPe3kaoz60PmdTQTjXkblTcqTkrDsSC7ytP0T/LIbYYjyYkdkFbwnRrU5YkS
         qsGzvhGEqjG7gEO6xh2ksNBszte3iF/VZiDwx+t938Cto77bb4G/4EfGS8Klm3gGIdLN
         Pjkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXTSiFK7fYjg0Vue4UqrgDEoiiepCLYbdg7zVqSuhY1E0SgtQJ/
	jdkQWNwEXIOvzA3+/m9jb5HlkdnhAaK38ao+2T/6PWxorsm5q3qjLE1UYn1eBJhgfeI+5M4UMDQ
	7eWNmtPeZy/19HbOAug1S5kSxa/NIWYrXEE/nLUA4mbHHrBJ195x8aYhmYH3jfwy1Kw==
X-Received: by 2002:a1c:968c:: with SMTP id y134mr74319389wmd.75.1563997737801;
        Wed, 24 Jul 2019 12:48:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyccq8ghS1siACkgzIARAHUi2+jxtFKB/EexCPgTkIaqbSaiFf3qBKGp4EfaRHfdEQdkfDb
X-Received: by 2002:a1c:968c:: with SMTP id y134mr74319368wmd.75.1563997737117;
        Wed, 24 Jul 2019 12:48:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563997737; cv=none;
        d=google.com; s=arc-20160816;
        b=TUMoqzeXOEvs7+k+X9kXJlncQjYCdmAD4m7OxadD6rRfKt2iuW9THfQf5guXkSYiPA
         4LHsOIXFeSfi3FtRqr3Qy+BzwCZMCg2ppcBovKvVj9AA6HB7UqpYF9uvl86krasNlvlA
         39a9xhApu0IDF1igpNIvJCvT5YfDQLl9MTUmumJNALk4lbODDkQ4DqI1oxxwlKgJeCkO
         atAAeE85kiE9gYu6TpcwFQQKDBDi6GM91xyjXXVZ4qcaTeNTUek/97NSlCLHtiTh+aXi
         N9OA/hYodzHlUcT98lgj8vMUBrz1H7fslJehhtEYhlmDLvY062ORaB9fZjgV6LJ9qlMD
         nfHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7Mw9NbtoiZQZJOpXdyhGv2HIjy5nvJ4CnKHyPITeaDI=;
        b=M59uBuPxZxEWt8UfuNFcM42y8jWx98oDl1jHdyAZSBxc/CZewbTAZ0kLCe7dcdnzbv
         tW4plrLgOYnEu+CBTvN36RUCiFqsQt4Ap/5PWBJFwpucwk+DvGnWOnV97WqoKKiisEv2
         tWX+vANhuj96ltHKWJ0jzamYHAu3hGS0lRZNVwwxKeavycTpAeV8PJRGBGsHWe+jOKNr
         jZR5KsMhLsjtIO7F0FKPKZSwnKIdWs18H6knRHG3pxPheLl63sHY1lXXzJN5mEJbEj8e
         3MiMmz+ggVRJC/a7FXR//rlGjszwYv8ud3vZmpXJjTdI88LFPm3NS2ZgbHyewm46UiWY
         29+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s133si37555905wme.79.2019.07.24.12.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:48:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id E520F68B20; Wed, 24 Jul 2019 21:48:55 +0200 (CEST)
Date: Wed, 24 Jul 2019 21:48:55 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724194855.GA15029@lst.de>
References: <20190723210506.25127-1-rcampbell@nvidia.com> <20190724070553.GA2523@lst.de> <20190724152858.GB28493@ziepe.ca> <20190724175858.GC6410@dhcp22.suse.cz> <20190724180837.GF28493@ziepe.ca> <20190724185617.GE6410@dhcp22.suse.cz> <20190724185910.GF6410@dhcp22.suse.cz> <20190724192155.GG28493@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724192155.GG28493@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 04:21:55PM -0300, Jason Gunthorpe wrote:
> If we change the register to keep the hlist sorted by address then we
> can do a targetted 'undo' of past starts terminated by address
> less-than comparison of the first failing struct mmu_notifier.
> 
> It relies on the fact that rcu is only used to remove items, the list
> adds are all protected by mm locks, and the number of mmu notifiers is
> very small.
> 
> This seems workable and does not need more driver review/update...
> 
> However, hmm's implementation still needs more fixing.

Can we take one step back, please?  The only reason why drivers
implement both ->invalidate_range_start and ->invalidate_range_end and
expect them to be called paired is to keep some form of counter of
active invalidation "sections".  So instead of doctoring around
undo schemes the only sane answer is to take such a counter into the
core VM code instead of having each driver struggle with it.

