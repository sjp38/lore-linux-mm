Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F1EBC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BECE220873
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:21:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MmkqwTBX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BECE220873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 382D06B02B8; Tue, 16 Apr 2019 11:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 330FA6B02BA; Tue, 16 Apr 2019 11:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 220956B02BB; Tue, 16 Apr 2019 11:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF4B56B02B8
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:21:50 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g83so14328729pfd.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:21:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kDE6LsgOQakIDdiu4qHhRwU77GOGYrkQmkOZsTSL0xQ=;
        b=da6CoqbUYZvEq4EiL4r5rbn5UlTCPn+JLl9CeCMNn1avf97lBjQKMZNT0bpyT0lYH0
         9zZH4dsnGF01Y7eCat2nPTcrd4ZSoBzBVi07JHBYl1TpdY/2WTsc3ArmbhizUPLX0U/n
         1pPlgaeO+8tCEHR1+MRif+LUw/ZiqqA2Qrc9ZkgVwqlLxr5eBjJpKEJnpvXVU+rSFAY/
         W3pYptK0YXai7wuNeMzEO0IvcHUb4Zq16CdFNkZjRLCzRXCm9pgSdF+E9X94WkFncuFh
         1iMAvnrUxnwBwQgZV+0JLiregt0GW8yAC/U4MUvuOH0mqPqp/CCAbOIGRFU5lw9JIgqq
         +BOA==
X-Gm-Message-State: APjAAAVFUMHupbiaubRm+bRH9+TFqL7rlMLVlKnD9KMv8wsLv6IgSCgv
	3BtaAnscgNQplsiXlFSeedUA8vV3mFHziYw4wJ0nccak0msikCPBNqGzVfKMftWuu1RIJWdd0ON
	sY7qFGcuT8EXjKqGe/0vXNmimZCS6MdsXGsSnjUNDHu9hhZP2HPFXHWMg3HYQ9il77A==
X-Received: by 2002:a17:902:7892:: with SMTP id q18mr82019511pll.163.1555428110534;
        Tue, 16 Apr 2019 08:21:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI4ELW9WOJHjea8JLiz/fU4OKTK0kGjUwMXOjaWQPAzdlzHZM86B+JsDCa8GBQa+a0OU9z
X-Received: by 2002:a17:902:7892:: with SMTP id q18mr82019457pll.163.1555428109941;
        Tue, 16 Apr 2019 08:21:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428109; cv=none;
        d=google.com; s=arc-20160816;
        b=t5qwG0gO2/SgkdMzjnR/e871x8BArz5AIvIOz5ak+TpDA/cIljmuhocTzuWd9oFxU2
         oij8z3L2iCS54aWIRuiBLpk2755o59LA0bqwf6708KQpD/L1MuIZoHUjy4PVeP/vVkTU
         ieplyaxGHg07PVgkXEkRf8507W6f3Zg/tFrUfSVqUGx2qC/kxMGkPt5eIPUWpfjKGEMx
         w1Su+svHbkbw8iC1TW/yIFWbG+LjYe2o2LAhSyVfqPgW5LwWBE01R2k/1qP0xb/N2zcK
         Xnvk6C2qqO2894pv/GR1czGEDkXmXvo19oK+aFrW4jMtuRO0FvpWTz5FuDymF1fRPn3x
         bDlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kDE6LsgOQakIDdiu4qHhRwU77GOGYrkQmkOZsTSL0xQ=;
        b=K2DPyHMOYXVxzotlaHJ5ctl3OSLuKmfEYlaekCboAm+QExi52nX6ryS94EeB5veZJI
         4FPJMQNj06P4235BLz3RxoUm9EECFSMup0upc3kalVBfW/EfabYX55dezTDA4Al06kny
         q1H+B01tzX8Gs5MIJOU7wUXPxAEgBTAGrbgmTO7LaY7QFD9c6Ha3olS9XHk9tez4CUki
         isiH2qEAzOOkTkHFSFA/RwLe3i4IKahjqyfDKqUHnc6RTYJ+L3GFe5n5gvI5XkJpdiJ5
         MTuNItET2ek53IprfwDAId+40dnSh9yKscVcKvvylo/+OmBZ03dTDpZKtk0Aw1gd/bDp
         0gqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MmkqwTBX;
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l71si31447950pge.428.2019.04.16.08.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:21:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MmkqwTBX;
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from linux-8ccs (ip5f5adea9.dynamic.kabel-deutschland.de [95.90.222.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3DD3320656;
	Tue, 16 Apr 2019 15:21:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555428109;
	bh=kDE6LsgOQakIDdiu4qHhRwU77GOGYrkQmkOZsTSL0xQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=MmkqwTBXCZQy197ssiG0bWuAIFQvdRgsiCFz8hBDpIz9wwsLgu3j11pdge0dAAhBu
	 NlTDpZYSqqB3RlIEwt6mVfqXtAuKnTtBWPU5mLGjkIp37lYfl3P3nYrOtMzfqvSjcm
	 pGdc+6ZEbcdbJiV4GXY379PngiwMUIZq+vlsBhwY=
Date: Tue, 16 Apr 2019 17:21:44 +0200
From: Jessica Yu <jeyu@kernel.org>
To: Tri Vo <trong@android.com>
Cc: ndesaulniers@google.com, ghackmann@android.com, linux-mm@kvack.org,
	kbuild-all@01.org, rdunlap@infradead.org, lkp@intel.com,
	linux-kernel@vger.kernel.org, pgynther@google.com,
	willy@infradead.org, oberpar@linux.ibm.com,
	akpm@linux-foundation.org
Subject: Re: [PATCH v2] module: add stubs for within_module functions
Message-ID: <20190416152144.GA1419@linux-8ccs>
References: <20190415142229.GA14330@linux-8ccs>
 <20190415181833.101222-1-trong@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190415181833.101222-1-trong@android.com>
X-OS: Linux linux-8ccs 5.1.0-rc1-lp150.12.28-default+ x86_64
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+++ Tri Vo [15/04/19 11:18 -0700]:
>Provide stubs for within_module_core(), within_module_init(), and
>within_module() to prevent build errors when !CONFIG_MODULES.
>
>v2:
>- Generalized commit message, as per Jessica.
>- Stubs for within_module_core() and within_module_init(), as per Nick.
>
>Suggested-by: Matthew Wilcox <willy@infradead.org>
>Reported-by: Randy Dunlap <rdunlap@infradead.org>
>Reported-by: kbuild test robot <lkp@intel.com>
>Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
>Signed-off-by: Tri Vo <trong@android.com>

Applied, thanks!

Jessica

