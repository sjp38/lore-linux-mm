Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35346C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0834520866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 14:21:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0834520866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 783436B0007; Wed, 12 Jun 2019 10:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732FB6B000A; Wed, 12 Jun 2019 10:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64A706B000D; Wed, 12 Jun 2019 10:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 186A46B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:21:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so26052163edt.23
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tQFkzsOty+X8TGYi9xgy4TjcwpTRqaHm7A8KtqJjorU=;
        b=RTtZkoUvjr9a6sPjJGSGt9DQ/s7/YxxRsSQbL+11bZQraWsVrdzAGh7VKUpF6NLVs1
         4ROQxdAq9o7ru6R3V2odFcy9j1CWDEGPAvqvBnYXccXuIJKRUfmEfiWyrBmoAmHluc9d
         dAp9w+dfvE8qOU2txDcfrVUpaVCpAYPZIWWVYczM3R4f1Qr8ZpHSRg70pcIBQ4NmffpH
         CqERm5MLlfcMiO0gf8voOhhL/Kz6931RaXXi59c33nR1aH6t34N0JD0xt+dq3hT4mEyq
         HqLHbmBcOnDC2rn/7UuTIjupdeFyBRhu/aiJvWflvPPyllHRCfuZgZSAabBsIEMoLY7A
         k28Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAX4o2TDPLlWUj09uy2HUVa5YFazPMQGv69cRmDf153NtO5MnwFR
	DqkXw4PgOY8zL8EnzcgCn3VHi/UyoUgE8YZRY7oxV58W1iugKIoARtOTLlWJBhhWuL0kPdHqL1F
	rK91nFIWllH83LeEKZyidiMktCNjSYX6c68M+mYySwvIi9snMzG56PIL+MPihiTrRNQ==
X-Received: by 2002:a17:906:2191:: with SMTP id 17mr9275366eju.157.1560349287602;
        Wed, 12 Jun 2019 07:21:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp+lTy1OTb3CLQQNa/W0/H2QMtfKXdk1JNDJTXEEoszw0KnSeeQdPb4WPKfxI7gLtdJwfm
X-Received: by 2002:a17:906:2191:: with SMTP id 17mr9275298eju.157.1560349286744;
        Wed, 12 Jun 2019 07:21:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560349286; cv=none;
        d=google.com; s=arc-20160816;
        b=swbS+QDPkTu4r7R3MVkMmYy5zsf9RsT/mvqJ0hG/eIIZYHqCP/cTvD2QGb4RzXpq6u
         2E6pd5SSFCPiqKn6N4VARDVRflc7oY/L4JTZ88auV6T/650NzyTV0kp/leKhDY7c8jRU
         +ehRuRPqDjHDRAKJ2y070X0pKCVSh2ulpffSnBKLft5fYsTjArGvm1MskERDm7Vi/ohu
         p9wU15cP+Z0kfkhW8YOhQZMSceygXb49Jv4HCrODD0aSatds5LfaiVzdsYhgQblrRfAC
         GtTMo7iCKa44mdrV7DEwrFQTHVajfn8uHpCTlMmrKjk/MIu7gMvZ1Xxbaght1SqCPmAT
         ysSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tQFkzsOty+X8TGYi9xgy4TjcwpTRqaHm7A8KtqJjorU=;
        b=fuSqWUWjHBrHWd2FT4AFY+MNOFOEakLP4BoF13YbJM6o2UvUYArxJQKGr+Dq10zhKc
         GQ6DfPzCzMmGI7wPtxLlZhDUxyLP/AH/4qDhuRZMMH16+VnGMTZGbXQOZjVZYxiVdn8Q
         JQMblxBJF5zVcqeOJsjvW20A8Aww03gw9Hy4xvRre8Hvkk2LwgP4F/R1VXAD7dsMQi3t
         Dt8piM/C3vnPf7OVrZrBxgh6Bhbmy3WIImjM6NI4ho8fzTX/ghCvQrannPyk2Fj7BLqp
         KHnlO2WEnv+qteYDJ70IF1oJb95HyLTfnrjJ8k2SIrlvO5x3h0q6WhuJ/zi947WLAon/
         sU5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g23si36031eje.302.2019.06.12.07.21.26
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 07:21:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D86152B;
	Wed, 12 Jun 2019 07:21:25 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7D4B33F557;
	Wed, 12 Jun 2019 07:21:24 -0700 (PDT)
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
To: linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH v4 0/2] arm64 relaxed ABI
Date: Wed, 12 Jun 2019 15:21:09 +0100
Message-Id: <20190612142111.28161-1-vincenzo.frascino@arm.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
References: <cover.1560339705.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64 kernel,
hence the userspace (EL0) is allowed to set a non-zero value in the top
byte but the resulting pointers are not allowed at the user-kernel syscall
ABI boundary.

This patchset proposes a relaxation of the ABI with which it is possible
to pass tagged tagged pointers to the syscalls, when these pointers are in
memory ranges obtained as described in tagged-address-abi.txt contained in
this patch series.

Since it is not desirable to relax the ABI to allow tagged user addresses
into the kernel indiscriminately, this patchset documents a new sysctl
interface (/proc/sys/abi/tagged_addr) that is used to prevent the applications
from enabling the relaxed ABI and a new prctl() interface that can be used to
enable or disable the relaxed ABI.

This patchset should be merged together with [1].

[1] https://patchwork.kernel.org/cover/10674351/

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
CC: Andrey Konovalov <andreyknvl@google.com>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Vincenzo Frascino <vincenzo.frascino@arm.com>


Vincenzo Frascino (2):
  arm64: Define Documentation/arm64/tagged-address-abi.txt
  arm64: Relax Documentation/arm64/tagged-pointers.txt

 Documentation/arm64/tagged-address-abi.txt | 111 +++++++++++++++++++++
 Documentation/arm64/tagged-pointers.txt    |  23 +++--
 2 files changed, 127 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/arm64/tagged-address-abi.txt

-- 
2.21.0

