Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B76C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B15E20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B15E20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEC7D8E0012; Wed, 27 Feb 2019 12:07:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9D498E0001; Wed, 27 Feb 2019 12:07:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8CE28E0012; Wed, 27 Feb 2019 12:07:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE1A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:24 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so7102327edm.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=T6NiSwMMvhnoe2vgI+8wifL/HFKKnl7ekrNCMWErvF8=;
        b=BXbzmDrlY1MJu3px5AobWfm8nl9R787w9R5XqutvOuZnS2qMK6s55hpZq5hdp9Ipg4
         CQ+jtGwKdXJ38Wq0QM9ez43OLQ5fFOCVoX1JBH7XKwdBtQHAV0YdGHYv3Zfm1ig99pmk
         55d4+W0s6Jxo5vrPpGdVWEi2q/7cqweceOJuGOA332TFe0SDtviFPsP4FxzC39uVY8lf
         B7VdL1P6h8vOH7fjI2c56LmVRaNiWZxxrvnfUICR1wDhG1XYsemBaZMY1+dNMrEMglJ8
         l9c1mOf7+wa9QLSa2vnQxKacHP0N1aA4kv/GIMK1tbox1i/7jrHqEBD5+9wUVEA/+wUw
         nJaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubMXuhZy7JB4S4AIq9+SmwYjUGIG/COv8Bxa4iAi/jWjtxX1GXs
	q8bxatNJNtKYqBM+NQnCgSrJTvxZ1tKhJPc6zWOyVogskmnVSTZwtn14fj1gsB664L7UxxuQM/h
	2iyeFeUhgMgISwXPorMtc/+n1FPNTvTkr+pYi/iCwyMWe8j4Vc5pY+cN6EJ5izpUDUQ==
X-Received: by 2002:a17:906:3952:: with SMTP id g18mr2229519eje.247.1551287243856;
        Wed, 27 Feb 2019 09:07:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY89YvPT5NNZtkeK5WkpENeNbrrdlgx015sMTrad+/5oxtc3ovJ9+Y/lXGzWzSODOgPuLVu
X-Received: by 2002:a17:906:3952:: with SMTP id g18mr2229446eje.247.1551287242598;
        Wed, 27 Feb 2019 09:07:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287242; cv=none;
        d=google.com; s=arc-20160816;
        b=g5eVpiXM6ptFJwZ5YQ83fHW+Yz92OehZefzH/6AI9zh7WwPdjCuqylZjNRo1BAxGoy
         6lhUE/d2P53cN0uakP6VpHroT45AGF3BKrmFb6qdA3zCtptiuEkH9Ob9KrCvFXBMgtnI
         vbKNoV8sVW0KVzjDTjtg6tK2b9aOCD7//IoIBU8rLcpx3lyfSjYmEi1b+4iMWl4Epdm8
         0KPZL7wJtUFstDBrsfc69fCvBhQuNld3h83qoOipNxeZ23s89+DBfwJsPVQD9LQ8IVNs
         97NBoa98ftRwErku8GZp17KDpzwMawSGZEWKLBO9vLtIXMo/aCjY35wXdUucnqsR2WBV
         8xzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=T6NiSwMMvhnoe2vgI+8wifL/HFKKnl7ekrNCMWErvF8=;
        b=NglpmAwO4y+aYpTwsfCsSju9TjG4zc2jcJg1SnZeUZMyiXNCnFKK1Y6ntiBjrtaRdc
         pkZDyiETK55AvDBJS45H0SL09zFzMHfTzbACgymH21U85uEXWy+0Pmw3HeOlcktJWsxv
         8pL3K8+S/nNrRRglc/FAIuRQ2NM0WmK9lhqQUQEuWYKCpYEX70dSF9avU7XYDq9GNaxp
         5KaGd87+51XLC+YJ7N+QLYVgpMmltpzhVuG2GAzMtz5TvkrMr0G5NJT3njunV5yV1x+j
         reIbSL4n1W/zmQ9L67z5616DrMdvVDFa8EZdB8UbiyvMSbD0F4EoUH/ZPgdbf3gu7GSm
         co7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b56si1818140edc.402.2019.02.27.09.07.22
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:22 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9F2011684;
	Wed, 27 Feb 2019 09:07:21 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CAC793F738;
	Wed, 27 Feb 2019 09:07:17 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Jonas Bonn <jonas@southpole.se>,
	Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>,
	Stafford Horne <shorne@gmail.com>,
	openrisc@lists.librecores.org
Subject: [PATCH v3 14/34] openrisc: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:48 +0000
Message-Id: <20190227170608.27963-15-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For openrisc, we don't support large pages, so add a stub returning 0.

CC: Jonas Bonn <jonas@southpole.se>
CC: Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>
CC: Stafford Horne <shorne@gmail.com>
CC: openrisc@lists.librecores.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/openrisc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/openrisc/include/asm/pgtable.h b/arch/openrisc/include/asm/pgtable.h
index 21c71303012f..5a375104ef71 100644
--- a/arch/openrisc/include/asm/pgtable.h
+++ b/arch/openrisc/include/asm/pgtable.h
@@ -228,6 +228,7 @@ extern unsigned long empty_zero_page[2048];
 #define pmd_none(x)	(!pmd_val(x))
 #define	pmd_bad(x)	((pmd_val(x) & (~PAGE_MASK)) != _KERNPG_TABLE)
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
+#define pmd_large(x)	(0)
 #define pmd_clear(xp)	do { pmd_val(*(xp)) = 0; } while (0)
 
 /*
-- 
2.20.1

