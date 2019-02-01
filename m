Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51C55C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 13:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E87FA20869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 13:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="P4GKAA7J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E87FA20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 392DF8E0002; Fri,  1 Feb 2019 08:20:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31B9A8E0001; Fri,  1 Feb 2019 08:20:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197BB8E0002; Fri,  1 Feb 2019 08:20:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADEE98E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 08:20:58 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id d6so2268776wrm.19
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 05:20:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7L1X6vKf/wnbcTvmjqUAGShbPUgIPy8g7a7ScRxOFMM=;
        b=e07ECp5F+A5Ffh4HqNE15uSR+e9VMazKciS/NxA7ZfFo6FnjGOm+3uBb7YlhOHS/Io
         2SVMtH1pUKJqfoI5Q1jWkX215StnNMoMjF81y8EghtxQGzN4VhPFEQu+Qy4cAG3H4tHi
         F3BzZRulOZH2csLqDP7gzHt1UCYLOtLmoGs2CXKv7l57pgkJyoE9j5vHIV9aUqAJGfM3
         y3X7+71uBelmhzibYDCyNCgqnHXJcxKJIzpr+dHl8o536LdpUgAhOsnsNpYsYIhMQlqs
         z1YyZJNh3/mbk7cvAwwIHH5o+p0SqyQj6iR2S7mLWveHMwRYQ8y1SVnjk8guTdIG5JFn
         plBw==
X-Gm-Message-State: AJcUukd9+zx7PD9gAB/ODI6Kv7UkBiLLtqM2NT1iZPN4ParyC+Ml7Gw2
	v8BifV3dGZ8ojGiseCY+7z5/7VgBTV+Xol0/+jBKsnB2jhljQCUcEaVTCMWqPyTZvHDcg4FFngv
	fLt36DTmqamPjuMJPNop2ArO5LCMsC46EE6l8llpj/hGSv5q+uApLBYHvj0bdYL98ow==
X-Received: by 2002:adf:bb44:: with SMTP id x4mr40214912wrg.24.1549027258092;
        Fri, 01 Feb 2019 05:20:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7LnnNA+OXHPrvsfYr21Vx5O9/iGXJij0AQ724VbBUCW3Z5RqJVFKrpC4UVIU5mn/Ekwfpt
X-Received: by 2002:adf:bb44:: with SMTP id x4mr40214865wrg.24.1549027257169;
        Fri, 01 Feb 2019 05:20:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549027257; cv=none;
        d=google.com; s=arc-20160816;
        b=rl/9gXsVwh5+5NMvQYg/acHlw3kgpM/bfx0ZOk72If3yjxzuV9DkkyMW/zPMe/Csb2
         TzKE48WwUdDJQcO5Jd2RVfKd/46VltIfHUOfD9yD289GoB+xM/cqaR7kU/OySTuiC8F9
         gPh5DNKJWYS2ZBlKhS/eI9/oJp3tbETalZ3FhoATU9BqDRlRLPw45awOuIZCF3QdOrW9
         TU6Z41kwm8xT1UBbNoqOqFDCoupzv7sbsFl6Z2VL04WfeRmR48YvwXelZZ7Mh/OcuBwJ
         THKywJh39YcCekUsZBqausd/YqLq2DITnkOUuyf2vQ/RRfSK0eRxYxcQo7Uh8teSxQqk
         ScUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7L1X6vKf/wnbcTvmjqUAGShbPUgIPy8g7a7ScRxOFMM=;
        b=oxNCD1xA0vngGWxjNlDbK/QR2ZIP+yJJqHPZiCQ2a7heQ6XyZKrXRQaLpXupodwdRh
         6To7VL0vTr0WRobrLZgK1PsJG64Pb00JfoQyMojzadkmHK9EtcosMVlLC+yckHMA+jFb
         nmv357JW+bgJaRVZlLNvhpmLDtzh3NieI3EJW3tNBOMJvogjB8f9ZKReCnmgfDxEDIpz
         O2+WMVoukQJWgonxCh4xrO1JWkcHZ9BCuWxK8TdV+oWROWH+f3Xx28fvtN/+Kc0SsexV
         yUYNgyjoXQQwdYwA7k2ZyoSi/K98vu2uwGOCwz9XTgajO1ORKkuKATYlQJgwiZCPYSIF
         R2ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=P4GKAA7J;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id k124si1951715wmd.157.2019.02.01.05.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 05:20:57 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=P4GKAA7J;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5000206D6264C5583287.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5000:206d:6264:c558:3287])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 456CD1EC04F3;
	Fri,  1 Feb 2019 14:20:56 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549027256;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=7L1X6vKf/wnbcTvmjqUAGShbPUgIPy8g7a7ScRxOFMM=;
	b=P4GKAA7JCnK8zMwSkARxItVovCaDmkYO3eSkRp4d1+WS0j+ZngXPe/Eux9wZ8zOzUVBsUJ
	AVicI0193MpIC9IQL10Brr8pLyCcYcRVv2K8fxgQtKkFCMjrvJi3WRKo560iAY+P0xYnEb
	vp7v7QRkio8eq24FzVGVezsW7d/Bnic=
Date: Fri, 1 Feb 2019 14:20:46 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>
Subject: Re: [PATCH v8 04/26] ACPI / APEI: Make hest.c manage the estatus
 memory pool
Message-ID: <20190201132046.GH31854@zn.tnic>
References: <20190129184902.102850-1-james.morse@arm.com>
 <20190129184902.102850-5-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129184902.102850-5-james.morse@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:48:40PM +0000, James Morse wrote:
> ghes.c has a memory pool it uses for the estatus cache and the estatus
> queue. The cache is initialised when registering the platform driver.
> For the queue, an NMI-like notification has to grow/shrink the pool
> as it is registered and unregistered.
> 
> This is all pretty noisy when adding new NMI-like notifications, it
> would be better to replace this with a static pool size based on the
> number of users.
> 
> As a precursor, move the call that creates the pool from ghes_init(),
> into hest.c. Later this will take the number of ghes entries and
> consolidate the queue allocations.
> Remove ghes_estatus_pool_exit() as hest.c doesn't have anywhere to put
> this.
> 
> The pool is now initialised as part of ACPI's subsys_initcall():
> (acpi_init(), acpi_scan_init(), acpi_pci_root_init(), acpi_hest_init())
> Before this patch it happened later as a GHES specific device_initcall().
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> Changes since v7:
> * Moved the pool init later, the driver isn't probed until device_init.
> ---
>  drivers/acpi/apei/ghes.c | 33 ++++++---------------------------
>  drivers/acpi/apei/hest.c | 10 +++++++++-
>  include/acpi/ghes.h      |  2 ++
>  3 files changed, 17 insertions(+), 28 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

