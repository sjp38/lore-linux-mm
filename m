Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A4FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:14:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 681DF218D2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LldSWTZg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 681DF218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 030038E00F5; Wed,  6 Feb 2019 15:14:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F22438E00F3; Wed,  6 Feb 2019 15:14:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13BC8E00F5; Wed,  6 Feb 2019 15:14:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F71F8E00F3
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:14:33 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id a26so1697525pff.15
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:14:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ZWTJA+BXV/mUt/YXqVU09nZ+82JU6YZvgTflh1wNL0w=;
        b=C2Dn/w5Qocw544qoX6iQnyZaPqyjKzAVi2dAt8cKhLfXNi7x3pLRcYS08xXODf4i2A
         3OjeNgxm6jbPrmNNQikwJ2luhvq4RPWjcNDTaVt53GlGRN6v9UDz28POwWmHHV7Bme3y
         f4rC6/yjJBG6ABaKHNnqejEdn7DfccKrWwn3uP2L2IlTy09fDPo7BicqPDDoD5UxG4Uq
         rK32BjprJAMwWqsR8/sDVCbQkvEdrH9kshX73J8d6UwsRBBL5+fOCuyXTu3VGFIOCLri
         yGqcRSU89pdMmz43BbEOWBy5bXA2osGGqidW6/at6Bem+GbRYB1odBbUCWrzU2E7IqqP
         MFpA==
X-Gm-Message-State: AHQUAuZXIzRPsYvzq2Uup5F/8dv7bKEBnRALooAy7zuP0PT9Ks72tuU6
	qqBIz3Vo47yFAboBWhmAEqlrTLypNBFj482eChSjA4VrkMYB2i0LpVkY8+ftQywAUtHNUkUwIOH
	Y5rIQ73n0mmQToQBfFoN1QCgw5RwXYImgAV+whEfoxEBhn2FNNZP2XfnhN6DH1CMVGw==
X-Received: by 2002:a63:b94c:: with SMTP id v12mr11120948pgo.221.1549484073191;
        Wed, 06 Feb 2019 12:14:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDUk/JraZhDE0CQTXsEayX+cJxEfTtPB62HPEaaGIZv/7R0yJnx0iy1HAoMMdZupcyh1jd
X-Received: by 2002:a63:b94c:: with SMTP id v12mr11120883pgo.221.1549484072265;
        Wed, 06 Feb 2019 12:14:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549484072; cv=none;
        d=google.com; s=arc-20160816;
        b=gEv5QN5s82XYuSsJqoOspXGjvoUqKByPZN3pZ/VmEmlUrbohyMgjPIOjGv27x6aogk
         moFXgEPV2X9+kurrxB/pti6fjR9z/JGwppd/NwojaNmitdGtg32TQFybtWHkbWCjShSE
         I5HTOiv4fO9U1qWwUllyShPJWC3c+goOqey0Btn0tMlr3iLCfif/TbJUmfamYH13K/SC
         eeaAgrlBhgoUpixxSXlmaHSMDWY8g6txTQXhNLuHxIpqzdP/qUCTx3iFlVTRUVZJ/JFs
         D8j6gnouTX95+5fKPe4pqpZpS3C190AJ8GiZM+MA7z2cgDuMimnnij1hUIF311WUDJkc
         3jTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ZWTJA+BXV/mUt/YXqVU09nZ+82JU6YZvgTflh1wNL0w=;
        b=p4SbOAErbPOax8IQ+DZy3o7BPWYteAdgILtuzKrj2vxz9HIHQv1VIMoX+RJkSRVXHo
         c7fROid0wztbWMIbdHOoZENqgXyPTnCCm6hedJoIJnpgbKSUG0tL+36ohS7ihzQvUnAu
         +5cvWsKXdEZV9R1mUQBp58TEIHw4OfGPHVkrViIrcSK3UK168ixNNLk1LDBqAeWe/hzu
         U4XYg0juEgS3BsKfUPR0hriqqi9zsC0MXdP8FclJeqdBguzA8vgaTTxmBj4yLJp/uFSQ
         1HXktevYb0i8niaVe+V6AEUIVjb5I65+/5NiU45LiSIq4U8AEaEQUHPaIdGgJtcdj1Vn
         MAZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LldSWTZg;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c139si7430407pfb.281.2019.02.06.12.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:14:32 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LldSWTZg;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8821420823;
	Wed,  6 Feb 2019 20:14:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549484071;
	bh=D/jyviaLgSda2+tt19m/3P0OWxLRwvwSZ0CI7AZU3po=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=LldSWTZgw7Qnu3m7DgpdJe/O3fRySBiF9x5ihc4fFM5ZNkcbnSpaDbuLf2s1gqalI
	 qx8l6W8sFMXpe85Q3jYp97Uyk3pjmIsVbzX3siDZlFWRgLV//nQDRKQ9pH4fuDjDWe
	 rqURUZjmRNNOXwspDe0A98cQHP3nME7OXYXak8Gc=
Date: Wed, 6 Feb 2019 21:14:26 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>
cc: Michal Hocko <mhocko@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, linux-api@vger.kernel.org, 
    Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
In-Reply-To: <e1478ab8-e009-9bdd-3866-f319bd7259a0@suse.cz>
Message-ID: <nycvar.YFH.7.76.1902062111120.11598@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-4-vbabka@suse.cz> <20190131100907.GS18811@dhcp22.suse.cz> <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz> <20190201091152.GG11599@dhcp22.suse.cz>
 <e1478ab8-e009-9bdd-3866-f319bd7259a0@suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019, Vlastimil Babka wrote:

> > Well, but rss update will not tell you that the page has been faulted in
> > which is the most interesting part.
> 
> Sure, but the patch doesn't add back that capability neither. It allows
> to recognize page being reclaimed, and I argue you can infer that from
> rss change as well. That change is mentioned in the last paragraph in
> changelog, and I thought "add a hard to evaluate side channel" in your
> reply referred to that. It doesn't add back the "original" side channel
> to detect somebody else accessed a page.

On Fri, 1 Feb 2019, Vlastimil Babka wrote:

> > Is this really worth it? Do we know about any specific usecase that
> > would benefit from this change? TBH I would rather wait for the report
> > than add a hard to evaluate side channel.
> 
> Well it's not that complicated IMHO. Linus said it's worth trying, so
> let's see how he likes the result. The side channel exists anyway as
> long as process can e.g. check if its rss shrinked, and I doubt we are
> going to remove that possibility.

Linus, do you have any opinion here?

I have a hunch that mm maintainers are keeping this on a backburner 
because there might still open question(s) in the air.

Thanks,

-- 
Jiri Kosina
SUSE Labs

