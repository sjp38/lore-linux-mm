Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A52EC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 564E221479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 564E221479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A216B0003; Mon, 20 May 2019 19:39:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCB646B0005; Mon, 20 May 2019 19:39:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB9FE6B0006; Mon, 20 May 2019 19:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1A816B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:39:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d5so10798366pga.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:39:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=L/YAyymG07ysPTic1cNgp79LkRQf5ImIl7Wx+d1tTpI=;
        b=aSO04nHvU0FZX6fgUiFib9bXVaWhsO4vFAFxlX4kNeNtlQADWE28wd1C8zrBT9rtd0
         cMTi3JoHQol2QTheoPEq6NsJDd55mxhEVvo3QglONCe+Ob2hUupv0EsNe2s/2yG9kjdS
         p0FOlVSozNKGfJyZc8ZpNL64dl0WTQtj919ajAJTtgDzytzAwnpF7qi0i/8FCNdBhyid
         KDHaYBKILOL9fcoGlI9MVS6rVhk1IKkF8kW9xTBIt62RfYut5c6Iv5gGFdKltnOeCbiw
         Io//qMYkL/HMcUtvcyy67S0bNsnFLlxxqiNNddVT1ragABe+9cIDVq+NEhVo0FWidn3L
         +m2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUzwOP5qsn1hFlY2s+WZMfhVkCIOJouFW5oh8LchwAdJiUo4UTt
	mg6oRC5Z8lmA4/vlabrv4gdd5OCRDQ9GpZuPEndzl/gioSVD2F/vX3GttQs2TjopomuTaGhkiOp
	YoW14rcRdtQnS7gEEURHmryWrNlFtO+PxqARxdJyNsLPakt5X1j5NYtYaCG1VB6b0Mg==
X-Received: by 2002:a63:3ece:: with SMTP id l197mr40404422pga.268.1558395545314;
        Mon, 20 May 2019 16:39:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyr8l9tRj5PPH98Ux5HxwUnrPDds/cuH+/AsISbySUycqY5LTM3zJ03Vn/PgOA2hHztKP/h
X-Received: by 2002:a63:3ece:: with SMTP id l197mr40404355pga.268.1558395544473;
        Mon, 20 May 2019 16:39:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558395544; cv=none;
        d=google.com; s=arc-20160816;
        b=ID99A6h8M9iHTeOITXiWSq2IavfnFn2KS6TOVqKkREnh++TIP0uERdx1wHmKkf1LEF
         bqNvQ7AG9XFzXAsSEKr7Dj31TG9WXFKbZqskA5bMhNQG69MD7nc8Z5ZqZMJRpbOyDi1h
         eYV4mlPpbpc2aiOBAEzVzCer2pBLMSkm3u54Z/OmknNV5Nit7HBTiFK7jmTyC+cMdsTL
         zLtr85/bw5lPxCC/x3amh8nI56d+dKz6gDWXJ316a5FoQEO4ZXujML/XLmojs8ekWv8D
         Tfv9ueHtf6kmhwnFlTNQ/90OvBL7S/RWfl3s5f0W3BgdaO4xGjCvBK1iRVLLJW3TqHGt
         hbKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=L/YAyymG07ysPTic1cNgp79LkRQf5ImIl7Wx+d1tTpI=;
        b=Ebsu/b19b6rzPtjFkfCP2FrWGm0DtZbZ/FuUlPDkY+HQtNN47niXlufEb1zpprYTne
         lAfUmiMSwdK5hL5HMm6w+v7BOEF7MkEtcmvy6lE2fETkQY7s5n4xy5I6yqro/zrvUyz2
         k2ktN216RlMhv/1CldUPsfC68eKmXy1SVhfNCBsH79DC6Gt45fvbG0x6/rx4SmnoHywV
         XNE81FrqvoLn/hVrPH3+Y2GRT6XcD1eWNpbgDeGmJ2+T3VbcHatF6Foj8SRagk/ApFjC
         1a4BBzFNuqocHN96cF+sxSjiwWACXuCPSOTtsha8GbtEKye4pFQF959H1dRYiANMSYf0
         zwCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g90si19915577plb.140.2019.05.20.16.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 16:39:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 16:39:04 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.114.95])
  by fmsmga008.fm.intel.com with ESMTP; 20 May 2019 16:39:03 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@amacapital.net
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	davem@davemloft.net,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 0/2] Fix issues with vmalloc flush flag
Date: Mon, 20 May 2019 16:38:39 -0700
Message-Id: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These two patches address issues with the recently added
VM_FLUSH_RESET_PERMS vmalloc flag. It is now split into two patches, which
made sense to me, but can split it further if desired.

Patch 1 is the most critical and addresses an issue that could cause a
crash on x86.

Patch 2 is to try to reduce the work done in the free operation to push
it to allocation time where it would be more expected. This shouldn't be
a big issue most of the time, but I thought it was slightly better.

v2->v3:
 - Split into two patches

v1->v2:
 - Update commit message with more detail
 - Fix flush end range on !CONFIG_ARCH_HAS_SET_DIRECT_MAP case

Rick Edgecombe (2):
  vmalloc: Fix calculation of direct map addr range
  vmalloc: Remove work as from vfree path

 mm/vmalloc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

-- 
2.20.1

