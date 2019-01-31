Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3A25C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69802218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69802218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 002588E0002; Thu, 31 Jan 2019 13:37:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECC148E0001; Thu, 31 Jan 2019 13:37:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E028E0002; Thu, 31 Jan 2019 13:37:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5BCB8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:37:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so4733802qte.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=KPWKir/sq0x95e20bcJglMpomUWDLhIE9o/JOfqXUGI=;
        b=m/L3o7RwviU6Q1ujMuWgRZ876WPRVl2tl3C+itNq31qYk4oALxxDNsmVlvhQcd2m6/
         V8NIQtzNQVAOYIMixB1WCLp7fXsRGtqVXXLVmKYCT2Ijm40Lc77yT3aluqD2AxcKJtly
         Nr+qLPGVqW3WI9N9wpMDX+yzvuO/DA+8uo+gZbArp1baxedVWnAHaIiGfNaGq2RnFyMQ
         tqYYSS7fxMkAc+oMTA3Oj3I499o9qUXUCpA4W6C8YS569rDMHuyP3l6jNDu07+CYsGeZ
         HhLjsKoW+aLQmOcMFHEomwrEVhGf42ReI/B/RjNc6iWRn81b1HfsooWMIxI0gbdw25JS
         rj4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukedKTPjG1GOaaGMabmGq8JaGKgc9ZKXJoP77Br7JQgmxgTlaNJG
	mZonvIqGPCG9R90Cl9lJLBmxSyCawcpK/AOwmvrfAeJzOryENCyxfUL6L/tHj+ex5yNeTMb3+ne
	iQ+myE+x/p+afPo8cSbx3tzX+RWzb0LQLtrEwLRiTtvPJPPUMM1EQUfj2Flp2mY1WCg==
X-Received: by 2002:ac8:760f:: with SMTP id t15mr34295991qtq.188.1548959837346;
        Thu, 31 Jan 2019 10:37:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6CFGresBfDkv5qUjOTMB9LzPIm/aJ0Y/gSjt6MSDu5np36I6B6BzldfPn6VllPeC1S8MDz
X-Received: by 2002:ac8:760f:: with SMTP id t15mr34295957qtq.188.1548959836753;
        Thu, 31 Jan 2019 10:37:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548959836; cv=none;
        d=google.com; s=arc-20160816;
        b=McpfArckTLJ1Eh7FcOEcRiNHXxMeAUtinCoDva2w1ikQ1tbqSA79VEn1vboCj9PrU/
         Tpg+0m/p0TnqqMkAb1ePPsZATZ7P1A3YrpfZhAidUMSTR+lE9RUzx+F2BkCFIf7TQMIn
         GWnkW1hdewgZgRpYHZTYImRS51A3OtGnCiYcYYUiN42pkxZqG5Sf/zzvJ3N2micJ42DZ
         9/2GgfYRf6n5eMfpzN98uz4+St5OpgBAhS0fWM4KM6TDrsf3m1OrdhTlLl+4Ft7xG7/V
         +TmaSMQp6JunCKOkpZjqW/7nvg2gTQsE6jLY1/HuOoHNkjCRaamJZdGrJFx94JYOpnSn
         Kliw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=KPWKir/sq0x95e20bcJglMpomUWDLhIE9o/JOfqXUGI=;
        b=PRAueLf0aumUSIJgTaT91aHlh/aI5FHbN+FbcaR8BsNSp9ISvCE6N9n83a6HvNExlf
         eWH+L5F9Le1zrWSxfdiXYk/9swKJHBGT9uvvj7A+P2mGhUt/kgxfBAyvYlsXpd6ec05a
         ronF9w9DNaIh9KXuWqr9WCPExldESenPdI0Evi8CXmdWtqYOsqJk12sklQEobnqlc26Z
         X7JGjVqe2X67LWwnTfYg8+s3VbwHyclL7AYKHlR2O5plSUjdzYsCc33/EeR8lDw78/NO
         ccGcXc1tYMiQQI/chvfBEiYaTkifX73e7eVnMk3IpEt1UVO3hNZw0PgAnSdE+puvIRm7
         fsmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h34si3854403qtd.155.2019.01.31.10.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 10:37:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8EEC4CCB60;
	Thu, 31 Jan 2019 18:37:15 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BBCCD19492;
	Thu, 31 Jan 2019 18:37:13 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	kvm@vger.kernel.org
Subject: [RFC PATCH 0/4] Restore change_pte optimization to its former glory
Date: Thu, 31 Jan 2019 13:37:02 -0500
Message-Id: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 31 Jan 2019 18:37:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset is on top of my patchset to add context information to
mmu notifier [1] you can find a branch with everything [2]. I have not
tested it but i wanted to get the discussion started. I believe it is
correct but i am not sure what kind of kvm test i can run to exercise
this.

The idea is that since kvm will invalidate the secondary MMUs within
invalidate_range callback then the change_pte() optimization is lost.
With this patchset everytime core mm is using set_pte_at_notify() and
thus change_pte() get calls then we can ignore the invalidate_range
callback altogether and only rely on change_pte callback.

Note that this is only valid when either going from a read and write
pte to a read only pte with same pfn, or from a read only pte to a
read and write pte with different pfn. The other side of the story
is that the primary mmu pte is clear with ptep_clear_flush_notify
before the call to change_pte.

Also with the mmu notifier context information [1] you can further
optimize other cases like mprotect or write protect when forking. You
can use the new context information to infer that the invalidation is
for read only update of the primary mmu and update the secondary mmu
accordingly instead of clearing it and forcing fault even for read
access. I do not know if that is an optimization that would bear any
fruit for kvm. It does help for device driver. You can also optimize
the soft dirty update.

Cheers,
Jérôme


[1] https://lore.kernel.org/linux-fsdevel/20190123222315.1122-1-jglisse@redhat.com/T/#m69e8f589240e18acbf196a1c8aa1d6fc97bd3565
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=kvm-restore-change_pte

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org

Jérôme Glisse (4):
  uprobes: use set_pte_at() not set_pte_at_notify()
  mm/mmu_notifier: use unsigned for event field in range struct
  mm/mmu_notifier: set MMU_NOTIFIER_USE_CHANGE_PTE flag where
    appropriate
  kvm/mmu_notifier: re-enable the change_pte() optimization.

 include/linux/mmu_notifier.h | 21 +++++++++++++++++++--
 kernel/events/uprobes.c      |  3 +--
 mm/ksm.c                     |  6 ++++--
 mm/memory.c                  |  3 ++-
 virt/kvm/kvm_main.c          | 16 ++++++++++++++++
 5 files changed, 42 insertions(+), 7 deletions(-)

-- 
2.17.1

