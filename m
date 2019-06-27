Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF0B6C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE0F82083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 12:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE0F82083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D7798E0003; Thu, 27 Jun 2019 08:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 588D08E0002; Thu, 27 Jun 2019 08:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 475E98E0003; Thu, 27 Jun 2019 08:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3198E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:48:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so5870796edv.16
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 05:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=vX0WNZwdF3DW0KTKR0Wkmszsjql33DA2/oAzcqt2JrA=;
        b=cILEm+zn/1cHROTwnYsE/AAIuXkLkEBkW92qo3SzUoSBjGMOqJA4wi6LG2Y9h7gOE8
         ZrDTgvG4dXVC+tpFiCW8PgJpCsL8pnB4tnMo2OaxwzKtDpEABuMoSCOO3EIJr5Uh1rP6
         Ib0AFNqSQyTTt54WtFrhw3xUfNIXqUMGO5wx3V/G/GUg2N5lYrtVoDdP9baHwsTdVlq/
         h9ygpU5UT+QEg3d3HEqNEZ6ArrKupWJ52Ni6c1raGUvRZzB0fyMCHkHCMV/eVLkPAqjr
         4fEYmGqcNzdyoiz/ruPMMRRnrOBWyX6xJTV2PUydF/VaXQ2eUBXr0dX3qDDDHbgcvc31
         U1tQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVy1/aA/4IevKQgCfBhU5NOSBof46hJNEQTwy6BVLZz4Q+If8uA
	dyZcjRhw6wxiJd6f3MHGzjHbbV9JpVaOlcw38FjT07Z8I0IfaWr/Qj0tuTfiaZM23dMfLo0yF71
	6Q3DrpD7MGHPP6anprJsZW2llUdbm8wx48RHFfkyh6AabjOQIvE6PivKLXe4cACfCDA==
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr3893773edh.189.1561639723505;
        Thu, 27 Jun 2019 05:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrLfe4PvSKQLEQqrN3rv4PKCAmBBT63nuVa80eRIK3XXUBTzFnM1Uhy3Grw1Y19sswFQvz
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr3893721edh.189.1561639722771;
        Thu, 27 Jun 2019 05:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561639722; cv=none;
        d=google.com; s=arc-20160816;
        b=eCWcKsw/7WdUWjCXBsPQ+fSa88yVimHPKdD3qgYt5KRyOAtggLXfSjM9QSpDNTNqHE
         k+OwCdRFavGUrtSiKdd1xWFSlkn5M96m3aWrmojXZrUkzFuwjhS134ztECqIMnAxeurH
         usatM+7PwO0vPa1LJFRfElHi/MQ/yfhjc0pTJUM+zkSP85wTngOzPvbg7oy3ZhhBhOjZ
         0GVkfzxepEV/1j6nVenzt6f/4rbUc/5Is5WG3RxMNK1QpXna7ppoLy/jmyon8EeK4dkD
         KuKHJcMJy1GKmQXXEcvbkpxId7r7IElsmB/aAwJJKlbw+gudH/av/rCiaJ4epF4YOIA0
         72fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=vX0WNZwdF3DW0KTKR0Wkmszsjql33DA2/oAzcqt2JrA=;
        b=eUTl6QKyb14m+1JIkOxYWPHW5rg8nwjO4lcB4r7DxV1djQz/2iXCz+2oIYPaFbI5qs
         DfCAm5neHZOGvKrb8EDomUXourTRMzJGEB99DDpzLb4hUDGh5lNk3D6B4q38Pu4z6fgi
         /skFMZEDFwqadXEYANcxtnVFrStZVM/AqlVGOAH6WNe2/3WK1Kr/nxRrtGduDFSDah9H
         HUiiXvnprC64QtYaby7znsz/qSX30dGHUeVS0kxjY7UcWnkrFWgO6HXyXquA6x6tfeaq
         8/Y/KvaccxhHIsD085Gtg2fyPTqj1ZA6wey5Di3Bsm7pTo/C4l8fejhPE5QWYbM9GhFd
         tdxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y6si1386344ejp.270.2019.06.27.05.48.42
        for <linux-mm@kvack.org>;
        Thu, 27 Jun 2019 05:48:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DF6942B;
	Thu, 27 Jun 2019 05:48:41 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.20])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 9656E3F718;
	Thu, 27 Jun 2019 05:48:38 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Suzuki Poulose <suzuki.poulose@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 0/2] arm64/mm: Enable THP migration
Date: Thu, 27 Jun 2019 18:18:14 +0530
Message-Id: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This series enables THP migration without split on arm64 by subscribing
to ARCH_ENABLE_THP_MIGRATION. Before that it modifies arm64 platform THP
helpers like pmd_present() and pmd_trans_huge() to comply with expected
generic MM semantics as concluded from a previous discussion [1].

Initial THP migration and stress tests look good for various THP sizes. I
will continue testing this further. But meanwhile looking for some early
reviews, feedbacks and suggestions on the approach.

This is based on linux-next tree (next-20190626).

Question:

Instead of directly using PTE_SPECIAL, would it be better to override the
same bit as PMD_SPLITTING and create it's associated helpers to make this
more clear and explicit ?

[1] https://lkml.org/lkml/2018/10/9/220

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>
Cc: Suzuki Poulose <suzuki.poulose@arm.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org

Anshuman Khandual (2):
  arm64/mm: Change THP helpers to comply with generic MM semantics
  arm64/mm: Enable THP migration without split

 arch/arm64/Kconfig               |  4 ++++
 arch/arm64/include/asm/pgtable.h | 32 +++++++++++++++++++++++++++++---
 2 files changed, 33 insertions(+), 3 deletions(-)

-- 
2.7.4

