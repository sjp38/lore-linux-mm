Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54552C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 21:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 118D42146E
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 21:56:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bXiPb+jj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 118D42146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E15E8E0003; Sun, 17 Feb 2019 16:56:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8913E8E0001; Sun, 17 Feb 2019 16:56:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A4B48E0003; Sun, 17 Feb 2019 16:56:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFAD8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 16:56:01 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id v82so12252840pfj.9
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 13:56:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0wmxiqqk7vAqmoD3PZT4D63Pg1Meu3+th20mrox0DOk=;
        b=dp+yoghQq5SSv1k40+9lBD/Tomg6QMRMAx1lecxTjhIL5TSqJVmUoDsgoH8LmNABSy
         ShhONxzcvj6sr+531yEqfE5rOXOXO6aVwDvA9lwjem7SPRJkZrGaKKBw8UeI3P9BGMTk
         1rREBrciSDJgsHFFke3frZ7+ekNnpk72eWm3wU12atbXGBPXwf92/Q0Cvd9v8/bpjy4D
         2a41YJcGbPrmPxC3AaluIsZ+pKlTBbjfTic7UjTLOiG9Ue+oGxSjSitPmSYTlXqYe6A0
         hVdQJXNKpTjehdlakF+uI4CwO1Y5ED5fEVDvOKjRazDCa7Ugg/iurznyMTNjrISOFKmJ
         tvRQ==
X-Gm-Message-State: AHQUAuZzACGlWaz8EzmCOuKf+EUpbVgyxLqA8xwXqbLqX+V1Re7LkgA6
	5Lf5ofY4Ms9P1UgQjpNkMcUtM0qiL1iHzX0h2Coyot2hEFjQP7Me0ftZzfh7cgjl1hdFe09o3Cs
	VV3T1PGB5qyGUkH7bKhfcAj6tPyXN0uvz3OfQbOiv0Xrn0DUSGjwUw9+URvRE6gHUe1RqTlaukb
	fBTyPPuLln8U621+gMwshaBYooVWF4VTurKCHgbWryAlIuMT2RwS1Fqt+P8aS2b8WKD5ZGDH3hz
	FXLGlDx1NFVgBwKRsmcKKoxJFNGjIRdxASe2/kgdxscROYYRzIvqNRk0c8TUkmrz3Ww7TKke0bv
	uVjlt8uwXBs4X7NbmICYuyc3zCnX3AYF2ZFFuTtR/d53N1JooiglXvP6AoPFEq+2+TIJpxOzjGA
	o
X-Received: by 2002:a62:76d4:: with SMTP id r203mr21232867pfc.15.1550440560938;
        Sun, 17 Feb 2019 13:56:00 -0800 (PST)
X-Received: by 2002:a62:76d4:: with SMTP id r203mr21232805pfc.15.1550440560010;
        Sun, 17 Feb 2019 13:56:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550440560; cv=none;
        d=google.com; s=arc-20160816;
        b=pe/+dEtMQinTV9ZGS5Oh2niL/8lHJ+QKh96GTP2nuOI+Cpp9bDHqUin06zwA1IMoRT
         Eu4stS3Xc4gjE3YnZ47YROp6wTRA1ye9HJj9Lba+md0pp6MiajDl0IyHyIjWG14JHc+9
         Q2pDGLMaa+TUlGxJhZ9SNdXRqDeQf3wCdfGoQBwR4l7C6W8pTCKp6HCMEFjecwayyQzS
         CHgtcTKSHlP5rl1hC98unIiTaXq4Eos1tgw8i4Au/0I9B795nTS6ntwxRRP6gVYtNFfa
         vzpWGDuVmS/tIIRcIIarq/4xH28pFy1Ce2sbunh8MlkXzoRMs32rht6HiMgjWdk5Zsh/
         I7uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0wmxiqqk7vAqmoD3PZT4D63Pg1Meu3+th20mrox0DOk=;
        b=jB/oN+m6zrfngtrUtYZ57ZT8XPJ82kL7Xj3NIAp9PyZmuWF9uHjlnLlYeSA1SVQGGn
         yn/2Ico209weQg6WT/yjekzB1L+LGxYo0Oqdn1N1Zd4fO7iMKYYTefoCoLkNeOeUDb2x
         WEbBaZa0e6Sd8siDpSblE6010MX8RE+78KxkB8qisjXR34/Nh8qTuPkVZGM8Zjxv88UQ
         71nYUeKsqe6gpsz0yRt8GozkqIm2NqLZ8XV25A+4ZccBFn0SOVs44PlpiQZ8CXU/hAXC
         K6YeNWhqzw5KSooJhfJNf3XvKk4z3MHwBG/fLP3j06kDQMT2vsmToNRjG+NtJcARwXEp
         L9jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bXiPb+jj;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor17678156plx.42.2019.02.17.13.55.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Feb 2019 13:56:00 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bXiPb+jj;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0wmxiqqk7vAqmoD3PZT4D63Pg1Meu3+th20mrox0DOk=;
        b=bXiPb+jjfszHalIcoiGQpr79ma8nHUzFESYIQEBjgvau7dlK3K1YyqqgkSGMsyuTAN
         oi91PYriZRkfrrF/V8hoEH4ml69BOQMHy86EvXVDzpK9wlww8T5kstXI0AMa8MqsFZ8z
         3fG41To4sZ5ucp8bstPbknWBHxLatVJjmDIUOxEoyMVB0DeNxDf6UGbs1vZoXgD8zalt
         e3smdskO9nQgH11fmjyY+g0kVftd5WfwBF4+keK2y5lFUDra1xiQJRWIFzHKCkLDIkDh
         lSKxg/2+KIrGF33aPuTrHYpSBVlfKgeEfJ0cPEw/EYfT2hvYkkv1+NJtoq8qq+rwXG8Y
         Se8A==
X-Google-Smtp-Source: AHgI3IbqXw5YEK0XINbUyF5eYSMqG3seFTkN2WP0zeb+/N+xaXLutf2s82q5LgbDabqLwxuFqUbxag==
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr21903651plb.169.1550440559472;
        Sun, 17 Feb 2019 13:55:59 -0800 (PST)
Received: from localhost ([203.219.252.113])
        by smtp.gmail.com with ESMTPSA id k74sm5381900pfb.172.2019.02.17.13.55.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 13:55:58 -0800 (PST)
Date: Mon, 18 Feb 2019 08:55:56 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Segher Boessenkool <segher@kernel.crashing.org>, erhard_f@mailbox.org,
	jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due
 to pgd/pud_present()
Message-ID: <20190217215556.GH31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au>
 <20190216105511.GA31125@350D>
 <20190216142206.GE14180@gate.crashing.org>
 <20190217062333.GC31125@350D>
 <87ef86dd9v.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ef86dd9v.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 17, 2019 at 07:34:20PM +1100, Michael Ellerman wrote:
> Balbir Singh <bsingharora@gmail.com> writes:
> > On Sat, Feb 16, 2019 at 08:22:12AM -0600, Segher Boessenkool wrote:
> >> Hi all,
> >> 
> >> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
> >> > On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
> >> > > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
> >> > > rather than just checking that the value is non-zero, e.g.:
> >> > > 
> >> > >   static inline int pgd_present(pgd_t pgd)
> >> > >   {
> >> > >  -       return !pgd_none(pgd);
> >> > >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
> >> > >   }
> >> > > 
> >> > > Unfortunately this is broken on big endian, as the result of the
> >> > > bitwise && is truncated to int, which is always zero because
> >> 
> >> (Bitwise "&" of course).
> >> 
> >> > Not sure why that should happen, why is the result an int? What
> >> > causes the casting of pgd_t & be64 to be truncated to an int.
> >> 
> >> Yes, it's not obvious as written...  It's simply that the return type of
> >> pgd_present is int.  So it is truncated _after_ the bitwise and.
> >>
> >
> > Thanks, I am surprised the compiler does not complain about the truncation
> > of bits. I wonder if we are missing -Wconversion
> 
> Good luck with that :)
> 
> What I should start doing is building with it enabled and then comparing
> the output before and after commits to make sure we're not introducing
> new cases.
>

Fair enough, my point was that the compiler can help out. I'll see what
-Wconversion finds on my local build :)

Balbir Singh. 

