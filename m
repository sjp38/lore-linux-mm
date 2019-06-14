Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91D0EC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 580FE21850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 21:56:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="p0C+DG54"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 580FE21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAE986B000D; Fri, 14 Jun 2019 17:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E384B6B000E; Fri, 14 Jun 2019 17:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD9186B0266; Fri, 14 Jun 2019 17:56:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A46D26B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:56:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l4so2673812pff.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:56:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc
         :subject:in-reply-to:references:message-id;
        bh=TOyYQXc+pzm1AqW8xHDhR80HhcaLwYzCFUnP/1kwnDo=;
        b=FXWpTbFw8MUMdmbDluwcR4KX8AL113j0MpNbXsxpRB2N0qTiaIGu5Gce+hCQXcJXhP
         riguLC262iCTXhSwa6OobcKUelESIOlvLCP5SZhM6lpgrBLqKiyS8MktMWOjSHLZFbml
         uAWbrcmk+wF2UhZBJ1UGH6oIDIAhW4LZvRTJ+o8FqXucm/r2jmAcn1EoooUhuEOXuT0L
         95Y2hlQJM1F6VzYyhZZWEAv3TSKZEh4KEbFxXAoJhJpr+3Xy9jFK34+v98OpkT97/AUw
         nfLnZnj0k0o1cfPtHLuEhYklVyzKha3tYM8kynk0d8g0AWR9VVDrHUidmQSVxvsvPlew
         dFTA==
X-Gm-Message-State: APjAAAX4I2cQsd1x24EHcMgcQlvaGD7OS89B0f5oAIQ9tayiWao5RZzR
	1L3NH+yFNzFsm1XHDkZaG7nm487czMkZ+nqko4CRhp8pV7fzVLXFKeN3F9uH27t3i8DdHE1RKJO
	NImqwu6oOgKj+NdPM8XQxJFjFliNbGNii1nfAdos4m96+xmIgEgLPS2Ms4MeZ22KsOQ==
X-Received: by 2002:a63:e60b:: with SMTP id g11mr17491745pgh.172.1560549403296;
        Fri, 14 Jun 2019 14:56:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYT9hXDPodcW4oj8hMqr8i2HZ/CtR1Ype8r2GT8Mke2Q0TZNjnQHRiH9DzirPJmIYUjnAz
X-Received: by 2002:a63:e60b:: with SMTP id g11mr17491720pgh.172.1560549402730;
        Fri, 14 Jun 2019 14:56:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560549402; cv=none;
        d=google.com; s=arc-20160816;
        b=HNFSN1JKA3PB9xE8Bo0utPmbsBJatE1ej+rP7aCCMIb7nyiIY+j1Vc09fg0dIc7v2a
         y4vZt04P0LJCTbqUQd9lYB/Do9+4e6aic3e4vq7+8NbXnFx5KNIVspMh0Ls6NHcXiU8N
         u83prGRb5yBnw87MjR4PJjQx7HSLKzVppYDLVTbuxCHG3EA0Flj+Kq+mj15olGalHc+s
         b5yxLbfmnMY/22Ck2W8QNL0MdLeE6atyCLtt0kvf2EFiN5F7J2wLTlAoJeehMaIcawJP
         gtohYaAjGGsBdeQlKdMnGYb7KqJePTV0HFd6BN0mdms5D0Y8kwu71NBaR0sZH/9/34/e
         TIfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:to:to:to:from
         :date:dkim-signature;
        bh=TOyYQXc+pzm1AqW8xHDhR80HhcaLwYzCFUnP/1kwnDo=;
        b=Rpqc4wB8Z4v2osajdria8EwzUaCsy+7LxcBbHMH8Lt4ML20b8jwNcNOKPaXehCrPMK
         P0Wt3IUfd7nmAVcd1HGhL+PQyf4G7D48/2pogzCd33UPaeucRJHP7JXH0LuukoZRxDVe
         pammWV/WEzZ++FdylWLVkdwcGBtScgrtJZ5FRoz4mS72h27S0JPYYgcTPg1OPr3QCwo1
         aRxnnhxvdEVXKMkZLwQRqvxWWAPqAJCaUyXoocuWG3MtuymMLEQU4fG6lz2gdyZAu8Po
         hS7SriohGs1lce7Xr4hafYcaywV23PxvO8CEqaKsq+/liUKhthiPpcK3WqBOVa1CtlLp
         rBWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=p0C+DG54;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p11si3112679plk.67.2019.06.14.14.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 14:56:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=p0C+DG54;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 31A5821852;
	Fri, 14 Jun 2019 21:56:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560549402;
	bh=D3Zc9tUrAePTRuXVs9aF6oFeeUXyXhoPrZYSLGnbOUw=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Subject:In-Reply-To:References:From;
	b=p0C+DG54HBcK+06VaJWWPPktw0ThAVYmAX2nh3ggh64TqD5xUXkxsYz47r5xoCrZc
	 DlfMT0G0fvwsNBbI0cIkeIsxfMxqimC9rSpqhLVSVX0b3KniI6oig45OSQ5r8EjoAh
	 LlRBhEf3h/lZ7RHCREQxeQOJUaxiYHIJDzAHCnJ4=
Date: Fri, 14 Jun 2019 21:56:41 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Mikhail Zaslonko <zaslonko@linux.ibm.com>
To:     akpm@linux-foundation.org
Cc:     linux-kernel@vger.kernel.org, linux-mm@kvack.org,
Cc: <stable@vger.kernel.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the full memory section
In-Reply-To: <20181210130712.30148-2-zaslonko@linux.ibm.com>
References: <20181210130712.30148-2-zaslonko@linux.ibm.com>
Message-Id: <20190614215642.31A5821852@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.1.9, v4.19.50, v4.14.125, v4.9.181, v4.4.181.

v5.1.9: Build OK!
v4.19.50: Failed to apply! Possible dependencies:
    Unable to calculate

v4.14.125: Failed to apply! Possible dependencies:
    Unable to calculate

v4.9.181: Failed to apply! Possible dependencies:
    Unable to calculate

v4.4.181: Failed to apply! Possible dependencies:
    Unable to calculate


How should we proceed with this patch?

--
Thanks,
Sasha

