Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1818AC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE32F21871
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE32F21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87C088E003C; Thu, 25 Jul 2019 02:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82BF28E0031; Thu, 25 Jul 2019 02:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4318E003C; Thu, 25 Jul 2019 02:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 235ED8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:21:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so31493942edm.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=nZiJVmCBU6j0vkuEoRayd5ClDIp3YWNTa2PYyQpF1pk=;
        b=ZkZ5+GSei/Kut0DTRsq3N1+DBz1pXMENsJZAV/pTAIHJEOqZjWd406b257Jf3rw2UQ
         oAwej7bSP6Qlxpu96YVj2hh1hMtPFHaK1PSiBa4Qz+XMKDDyAeXZdKe0B+PObhj+jKiI
         52VCEoNdOfXlk9JVCLXgek0vWWpFSNnZGVpfXo+KKL5u90m/Pn6VhK4z5HdyAS/1PZ9Z
         srUdN2uXfA32/8flDFYErFiyXlFSbspP4fc+QK/7yItJIvrGQ46hBTrUMnlAvrrXE3Pf
         vtkPnRVUL09Gsrd0/g6zzVNA9dUCLOQqG2Dbgys/oFWSO0V3y8m8NLNh/jxBopYoR6Wz
         yusA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWTz4926rjL4JBCITB5CMvN2aZER7j8DLMWvkKqBDgoZNt5SXUg
	1zIWgFKZRaKqHXN5O0KcAUROoeJu3Zsrbc1CzcVB8SVTPZP7RYSbkEAG+3pztVgb/LM+h94QV+S
	BSo3HRZ6wmt0+pbrVMrJuO5sX879QpDtvnm/Bvjk/j9/Ykh2lZ9lFdesEhNWUmm0=
X-Received: by 2002:a50:aed6:: with SMTP id f22mr75693056edd.59.1564035710651;
        Wed, 24 Jul 2019 23:21:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx173FXWScEin0e8atCRPYb4iYWzjXIqaC3MAIUGQNYSCGWpQrvDUOHOEMdggMevEI5ap9A
X-Received: by 2002:a50:aed6:: with SMTP id f22mr75693021edd.59.1564035709908;
        Wed, 24 Jul 2019 23:21:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564035709; cv=none;
        d=google.com; s=arc-20160816;
        b=N40rC02x19/q0/5ka4TMIHKko8lCLHIcQ9E3TqYDo5Hxmkyj804j+U3mBMfDABOwp6
         adWFU6jTmEH3HHWCGdAOq4YANMKqLuEqCmo357puHSAK7XZbpuaC7agSxj4w78rStSwO
         uNuu69lMFVT6WqkmoIYVvgtnLCbxfUiln6AfAIOH5zwNyEaSfbDdXBMM8XCp85Fo+rRs
         PV3QQsck2sTo8pLjZ5B83+WLLal+xFj+IryBZtUzZ0Lj11j17hcsKA35C5JepYM+vAbO
         fibpcVld83nTUzkRPNQjFBzrNYZOSa+rK+iBS3F1zYn8sOgjZ/NYWehEDbT3j7OBrw9Q
         G8GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nZiJVmCBU6j0vkuEoRayd5ClDIp3YWNTa2PYyQpF1pk=;
        b=lA/z402JjELMKpSJvwV0n2UnWpsm8a+cXO1v/CuWGNER92XgijEoUflqiM2PBUIvzw
         ybJhaL0xKn+rITrPzH4nTBIIeKhYtkSh+OIoZlyNvu94+Db+wSHnPqoUAqi0u17gjUiQ
         ksGy45z/jYCb9JcXElVbtRuUurhcnR8xvZ7OdlmcdHt6vQwn8YddScPy//AJw1qd085y
         zuD1hUHjFKxr18JWaSe4z2jF10O47OqmMDIiolMQ0riZQ7m9uzC+YniasVRX0SLqFBgW
         W7mgJdW8oud6mFIbP6Lfri5/yKgnfEWKAmGHGgiicqQEXpSFGQu82cZKm9pLAvZU8Mol
         LYSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id v29si11405034edc.115.2019.07.24.23.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 23:21:49 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 9BA7EE0008;
	Thu, 25 Jul 2019 06:21:46 +0000 (UTC)
Subject: Re: [EXTERNAL][PATCH REBASE v4 00/14] Provide generic top-down mmap
 layout functions
To: Paul Burton <paul.burton@mips.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 James Hogan <jhogan@kernel.org>, Palmer Dabbelt <palmer@sifive.com>,
 Albert Ou <aou@eecs.berkeley.edu>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
 "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724201819.6bhvyugquhfrldfa@pburton-laptop>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <9019120e-fc69-22a3-6733-cba27f8eab4c@ghiti.fr>
Date: Thu, 25 Jul 2019 08:21:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724201819.6bhvyugquhfrldfa@pburton-laptop>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 10:18 PM, Paul Burton wrote:
> Hi Alexandre,
>
> On Wed, Jul 24, 2019 at 01:58:36AM -0400, Alexandre Ghiti wrote:
>> Hi Andrew,
>>
>> This is simply a rebase on top of next-20190719, where I added various
>> Acked/Reviewed-by from Kees and Catalin and a note on commit 08/14 suggested
>> by Kees regarding the removal of STACK_RND_MASK that is safe doing.
>>
>> I would have appreciated a feedback from a mips maintainer but failed to get
>> it: can you consider this series for inclusion anyway ? Mips parts have been
>> reviewed-by Kees.
> Whilst skimming email on vacation I hadn't spotted how extensive the
> changes in v4 were after acking v3... In any case, for patches 11-13:
>
>      Acked-by: Paul Burton <paul.burton@mips.com>


Great, thanks Paul ! I have just noticed there is an error in patch 11/14,
but without much incidence since it gets fixed in patch 13/14. I'll see with
Andrew if he wants a new version or not.


Thanks for your time,


Alex


>
> Thanks,
>      Paul
>

