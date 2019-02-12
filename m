Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57868C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:09:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13F82217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:09:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hUf05cJM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13F82217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A10A8E0012; Tue, 12 Feb 2019 08:09:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 877778E0011; Tue, 12 Feb 2019 08:09:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78D578E0012; Tue, 12 Feb 2019 08:09:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 396C98E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:09:10 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f125so2049123pgc.20
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:09:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ZTUw4/HS+pH1olHabLxC4Of66X8O3JHecSHPY+IaFiw=;
        b=CrD5sD7hPwPofdKdsByoWUdpyK8UDGsLMWlkk1uXHrnnV2SOj9+sldrLIcB+AN5RFA
         JoXygOq7u09RzC3XdeUY1rLVT4BXBNnnONXu09bekuHgxHm6sg2ilvbuCUzN7dB9odIC
         lExLzlDEfYLha66v84UZrC8/Z3FTLPO8hM8U+QRPcv8uotowPPSL0YXo26aXZ6hdAORZ
         M8yQPzps7JjGjSNIn6+83b+37Lzm6exO5R9fOiqfJD1PV85N1vr+cPRtb8BasSB/pTOv
         l6Qum3coFebtInlQqcIoJj0Ag5AgO/BY3MUMB+q33Q+qXmDPEzflzQf3zScW9+NMSZUJ
         9u9A==
X-Gm-Message-State: AHQUAuZSLGrbDSvc3D5B4QlXxbxjwTAAmgSF3IH0nD3swlm4X+ny4Te6
	WNnAwZPH09e/SzRimJOk4p+0HeeJH9DO5N19O++tXUyOJKRDNYNUUjyytvdPAGIfr1uwJ2ofoSe
	etVgwGCiQQeEkjwvdKDdfkARHkP27dHKl5D0pzIwUQgXKazHopY0HBm7rz1V5bZNkrg==
X-Received: by 2002:a63:4005:: with SMTP id n5mr3543435pga.86.1549976949863;
        Tue, 12 Feb 2019 05:09:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia376sYiz3F7XzJ9ycZR+XvNRTscWvr4vHvYUVE+mmnOU8oLhyvvR+2EEYEXLQPMX6GLvuc
X-Received: by 2002:a63:4005:: with SMTP id n5mr3543387pga.86.1549976949134;
        Tue, 12 Feb 2019 05:09:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549976949; cv=none;
        d=google.com; s=arc-20160816;
        b=tI79CHqwxT79ICCc595iMGlLBKiNa9HtyugH2LK8uHecilssNOcj0TLdOsG4OUatoz
         S+SXLCyIaCTxkYm2ttrsyrLR3feKPuuXifaYNB0EMPJyb2BNDuiqW8tcvfa2wjuJ80ot
         FB6jx+rsJSx3LBdnxiBBQtdygEKOVyML1CQeB60WBsvHKXQQGX5WxoQLNOIPIw41RsZe
         GTrwJYlhi5R6XXlq/p/+in6nNKSxpUOsklOGiGT30dwHh4XtPKsnea6GS9VUqKKFkAFR
         RitmOtT8PiS8F1ql7tBP/Kk8DWZeJKCMyDQxH0eKs/iQ7CF8DeaK7NvPVM+Clp76VACO
         SiFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ZTUw4/HS+pH1olHabLxC4Of66X8O3JHecSHPY+IaFiw=;
        b=mp42ZLi95NPu1xLKo+Pnwl29hmAx1ZLQ3hdUtEX7C0EnYo7/rTN+JSp0WfXrEcD+TX
         DdIfzYg0r3mkzv1ySRKKtFdZQRoSxG7HMagn1TaT0QBKrq6kbQYk3zxh7H/ifoplJE7Y
         SPRm9b8U59rLvEPrk/qiMMhcVv695+ertvfbwVPHhslDyubJ+DqfzyOPC+3nwXaafubD
         7Y1V1Awn7bM0D64w50pQyGhuzLHEa7HjXHsfDDHWJankbhpQqp26DoHDjSWb6iJCqwUm
         MFYlRmKkXSx1l3q6P2fYuJoY+tXdzNlHxwWWlAeBGUljynxTjV5Drd9kl6ITjIj0LcUq
         0bgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hUf05cJM;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n1si1826262pgq.36.2019.02.12.05.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:09:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hUf05cJM;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6DFB6214DA;
	Tue, 12 Feb 2019 13:09:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549976948;
	bh=fNGrO4Z9cUqKFFi3SgEvqFc8Qs3lIpeumSpYFWUZoIY=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=hUf05cJMYzkJpBgq5qfmfo09arTbQIEkVyuFLVQ8M0QgIbGCHBr6TokNUO4hoXelk
	 +p5q/ABQDWYsymzOLraWRV19VheHRzEYxIXfcO3RbAKyYIqol3EzEbT/Ja7jtb6zKU
	 FdBPL/RflncvjMXlCLW9EvaMtiGzhayA7RIVCcnQ=
Date: Tue, 12 Feb 2019 14:09:03 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, Josh Snyder <joshs@netflix.com>
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
In-Reply-To: <20190212063643.GL15609@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1902121405440.11598@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-4-vbabka@suse.cz> <20190131100907.GS18811@dhcp22.suse.cz> <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz> <nycvar.YFH.7.76.1902120440430.11598@cbobk.fhfr.pm>
 <20190212063643.GL15609@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019, Michal Hocko wrote:

> I would go with patch 1 for 5.1. Patches 2 still sounds controversial or
> incomplete to me. 

Is it because of the disagreement what 'non-blocking' really means, or do 
you see something else missing?

Merging patch just patch 1 withouth patch 2 is probably sort of useless 
excercise, unfortunately.

Thanks,

-- 
Jiri Kosina
SUSE Labs

