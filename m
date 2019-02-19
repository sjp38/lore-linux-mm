Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B32ABC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:16:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E31120851
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:16:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E31120851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.crashing.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E01C78E0006; Tue, 19 Feb 2019 15:16:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D62EC8E0002; Tue, 19 Feb 2019 15:16:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C52468E0006; Tue, 19 Feb 2019 15:16:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A30A58E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:16:27 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id q184so6421039itd.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:16:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5cFL0F7EvFbGEdAV3fdM4boAn/nBJDhnhV/0YQUBvZo=;
        b=cYsop6mdc5101IjgRGrwOau7ccnyp+4CLI+/YdZALM1wfh4Wiprqt4fJw6QGzYQxQT
         djLy2tYkh2Q0L6mVn4IiCBRIfvNNitUlizfczK7a70CyoTf5Lw7Gw12O9s1kKFN1u+4S
         ZFyyAdRPljJZ9OP5SA5MwMR46dzHFtcJ6BbMDFCo/84Pb91u/3RS1kv98bvg99elx5Ct
         j3qT0RGOf//qeFhKD7A+/GUqLimjTtM53SOUtDEXbfOLy0EmwD4aBJ6vYeq14eg+2/82
         gBvlaBzzm/YYVtH5F1zNMRI/Rwf/gCtt9ywQReCjjVvEVtpkZ534+/lxZA8cNGb9y9wS
         6/rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
X-Gm-Message-State: AHQUAub5EA/VeGiFj5Gw7UgXyuqqJPtR4BRjqNJTGr3YgUXNxT85TAwq
	yCHIEzHwlzTrqSuTOakgG7Kxc2kDyj/TFGNM6A7OCmqqpJoRBQqmVhgtbihEFAWIl75Zn4DlGgu
	N0IzESk+FpFzXOvfiTdP4E8DAzuPURptABWiOnv1rVhsozMeOkSE/7AsDB3Coi8kR3g==
X-Received: by 2002:a5d:8903:: with SMTP id b3mr9263744ion.162.1550607387463;
        Tue, 19 Feb 2019 12:16:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IajgrQest/tfzRNw3fZiz3Gn2I++0JRrl26jEASPhNWNRwdsJa+u1xn9HF7UkMdiU3VVXW4
X-Received: by 2002:a5d:8903:: with SMTP id b3mr9263713ion.162.1550607386882;
        Tue, 19 Feb 2019 12:16:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550607386; cv=none;
        d=google.com; s=arc-20160816;
        b=QaQiwYfamAzQ8Y+0/J/gCeMx8VadrAa7xmUOk1ECF0hO22sFpxFoCIgVSHezcl12LG
         rvIm3KqEn6Zks3w4QOkkaHHuhTfqZsFAz/At5JlWwO8Fa4HKiJhzIdUoenNUmnfAHvYF
         594r8MtUKe6VMWmM0ANufvhQ05yIM6LhauRjZ4ZS1nipeD12dxGekhhnelt05YORO9fF
         3t6YtoGX56h178OGReq2Tnh727DbVyKlwiFqmyP9MeR3sacHNB7eLc13MPiglo3i6R3H
         lz816L06MiWrb5gUUYvqEF4eGgYkprMUXf4ryVKZiNF159nbklugMVi20s8OWW/S3tup
         70sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5cFL0F7EvFbGEdAV3fdM4boAn/nBJDhnhV/0YQUBvZo=;
        b=UBH+XJfaUCze50G7DQ+8vdayrUuaEbINVy6tvUETSsWhvoCNpjelju5Hb5DgQufaLP
         PVv5DTO3GsqgHZyPvq0ts39NgRdEQptrWMtmmzfoKAFFBTm0phruvOz6BO2/W3LrSdeo
         wh1hjXY68Q4yS2Dchtr2qFfc1QDc2S4soE+bAbQuoCFWIWOdSlScJs1A00r8oByCcEhv
         7WWFPOL9H6coaaxB71xSkTMykp6NySwqIHIUqKh+583aPJ+GGWMm0FH+HiEO0My40TC+
         ijNllMRxqGQyxyEZ45lsEwEbYu9QiToByuic9I4b6+FPtpVmaG5aVDChLOVj+lJf86fc
         AGGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 16si4024181jas.125.2019.02.19.12.16.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Feb 2019 12:16:26 -0800 (PST)
Received-SPF: pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) client-ip=63.228.1.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.14.1/8.14.1) with ESMTP id x1JKG2F2030402;
	Tue, 19 Feb 2019 14:16:02 -0600
Received: (from segher@localhost)
	by gate.crashing.org (8.14.1/8.14.1/Submit) id x1JKFfcP030368;
	Tue, 19 Feb 2019 14:15:41 -0600
X-Authentication-Warning: gate.crashing.org: segher set sender to segher@kernel.crashing.org using -f
Date: Tue, 19 Feb 2019 14:15:41 -0600
From: Segher Boessenkool <segher@kernel.crashing.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Balbir Singh <bsingharora@gmail.com>, erhard_f@mailbox.org, jack@suse.cz,
        linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
Message-ID: <20190219201539.GT14180@gate.crashing.org>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org> <20190217062333.GC31125@350D> <87ef86dd9v.fsf@concordia.ellerman.id.au> <20190217215556.GH31125@350D> <87imxhrkdt.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87imxhrkdt.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.4.2.3i
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 11:49:18AM +1100, Michael Ellerman wrote:
> Balbir Singh <bsingharora@gmail.com> writes:
> > Fair enough, my point was that the compiler can help out. I'll see what
> > -Wconversion finds on my local build :)
> 
> I get about 43MB of warnings here :)

Yes, -Wconversion complains about a lot of things that are idiomatic C.
There is a reason -Wconversion is not in -Wall or -Wextra.


Segher

