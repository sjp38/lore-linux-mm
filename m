Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 834F0C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:51:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 467AA208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:51:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 467AA208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D68358E0002; Thu, 13 Jun 2019 11:51:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF2478E0001; Thu, 13 Jun 2019 11:51:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBA508E0002; Thu, 13 Jun 2019 11:51:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF108E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:51:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so24116985eds.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:51:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r+wLOHNRb7C7zJsh+djyTX1ubbbS6C/CF4H05qQSUvw=;
        b=qcpuIJRLauY8Oah7wSf+7USYCHZT6ujv/yG/acDSMv+H1/mzSgrw//clL6XGbeqWu1
         Zl3wp0Z/1SWGmpN82S7WjCA9BnvTE7ZQ+wcrPDLPlUsv/wDF3WdRaKZSpFwPOA3NJEJj
         4BS5iHQqTb74jQQOkqCK84NHBOAMbMHzCfcsEgAWqiL2+M6ItXrE815jCAQIbf+f55sO
         QVPLhil7+KRIMIAXilLn7EKH/FvNK+5GXlG0/ns0ROUAcE+IhvZIy6dZL8X5NTHCa1ef
         MukWW4YsXd72HvVTH6q5CF6CmbcqkBSw57qviD2kAr/4l29QCwS8U+AN8y9vPm9zohrA
         5SeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXZF7Oxb3Zz0lWcf3mB0c9zNFXOCdnrH9U/fm3Gxlm1Z2cY9sFE
	mbNAsxKBEyB5IlTGtOsOLJIqk6jPQgWfA8Ej3BpA4baSg33M4A6Rva8AHpjtqWxdubyoS8OifJh
	PfgQdPZiLC5ZTVCJMFBvhDI6Qsq8HSEqj0OLENIcemekX05ZwejwRLqIktGNDh9VXxA==
X-Received: by 2002:aa7:cf0c:: with SMTP id a12mr23204043edy.146.1560441115888;
        Thu, 13 Jun 2019 08:51:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVtH63euGb0HzKO8EkGqcbnhUKIUEQHi3xij3mJQH4m1gSI3BLpglJe3dCwMPmSyzC7G0l
X-Received: by 2002:aa7:cf0c:: with SMTP id a12mr23203964edy.146.1560441115163;
        Thu, 13 Jun 2019 08:51:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560441115; cv=none;
        d=google.com; s=arc-20160816;
        b=jHHd1cFQxWtfGhmetkMzn2HszUvO3YdB96ad4zP5pVa7A1JuWBxEDr1+Hme95UVVeh
         2h7ZxZ/WELjsKGesrXf4xsuWw6NTfd+RpOEpb2S9BwtUUntc8Nth4KAKC71wMTNtjf3I
         Sp+OSLoZaRSROIAfG94OS4eYHJ+LHXUZcrtaiYSbMlByT+fIhX0Xa8dZ0F0fvF1cdWTG
         IYT/5+AKdYE16PzIVFWqY+v/jKDmeMHUoTaGYpQS7D0YLFafhy2786FO4H8kj12WguKv
         5SAGiulNy+sQXhZkl9RXKyPzQVI3Ol8eoXPscFDZKDd6vffcClBfwFWcXAvHQK0Z8JbN
         PqTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=r+wLOHNRb7C7zJsh+djyTX1ubbbS6C/CF4H05qQSUvw=;
        b=c7VSpPEjNBhmyH9kezNfw7XAlct3fy2n0r6sjuOLe1A9uveddNEeT9v42sFL15qFDg
         1ldxWyAu+4dtF8SPtRH53EgQ32G88IKvWQc1QrTcnYFIgBbU2t2gk+FbHkH/dQqR3ABQ
         UPC7ebD2Y3HsuL36RzVByDEgm2gpPEcEODZZ7QPUkRWtavxMWQSW1KodjT4D8Og6BWOD
         inSbgyWTTzg0c74LnVx6nuPEquB8MbHv0VGJhYkCcEgiP3RmkDwpVOBIkPLDg20iozUU
         AWi/IbVMiHnVH6FGIg5edGmeZO8MmQtvKQpiZcrN6vHoIv9TBgmTjt3bTt31eqXtlIEN
         a14g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id u2si208492ejk.197.2019.06.13.08.51.54
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:51:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4D8B5367;
	Thu, 13 Jun 2019 08:51:54 -0700 (PDT)
Received: from e119884-lin.cambridge.arm.com (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ED2FB3F246;
	Thu, 13 Jun 2019 08:51:52 -0700 (PDT)
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
Subject: [PATCH v5 0/2] arm64 relaxed ABI
Date: Thu, 13 Jun 2019 16:51:35 +0100
Message-Id: <20190613155137.47675-1-vincenzo.frascino@arm.com>
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

 Documentation/arm64/tagged-address-abi.txt | 134 +++++++++++++++++++++
 Documentation/arm64/tagged-pointers.txt    |  23 ++--
 2 files changed, 150 insertions(+), 7 deletions(-)
 create mode 100644 Documentation/arm64/tagged-address-abi.txt

-- 
2.21.0

