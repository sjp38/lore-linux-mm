Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7675C16A69
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82B0F217F9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82B0F217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBA996B000C; Tue, 21 May 2019 16:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D42F06B0008; Tue, 21 May 2019 16:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31C36B000A; Tue, 21 May 2019 16:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAE66B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:53:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s8so126903pgk.0
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=BLN9Ebt/WutrgbdJ7wJW1gYtlj9nwzx9znYKQRpM/t8=;
        b=ifFw8woHub9qq/L6pl1+1jd54SjI+vd3GiXkQt0JaNQFrvdU/RnkqdozgaLeh3m4BP
         X20A0nL/e57RpIY6izeGZd4IdWUrjkWcbl0RLdbDWkpoSquyBru6ToFYVibdfdKc+hip
         BNjLVkqUUokBNMCepCv+EkZ/zNKeqDGEf5YktXzPmcZi5LQ3sjO979mos0GA9eC9xvq7
         nRQAO8g4gC3g8DrPsQH+Lng6wO8H5pqf6sfCNgcxD8pw6jMkdUenLzorGgw0yiulqOEd
         D+J/pLMxBjIMfU0kPD7g3iP+GpTfj9NGVhaoaj5JgwfHlEDRrUM3AJVHfIs11sjXoEeT
         Xe2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXyQxY9uLtpeooF/Z2X70cE9pZh5wskox/K2Xru6EuDGqWcmw/e
	MfTJtwj8Ry5zeiTm4I7Z/yGPsk8lWHQCp4sOOT5zHzdMWPfnmS5kU5zoL6vw+lpAmyvej02Yl4F
	t+WNB9isNys0Zpm/o2BVYeDEVwCpQlwUzf7l0O3K9lqmdsgDJv3JyqTJTG3Lpsby4sQ==
X-Received: by 2002:a62:5306:: with SMTP id h6mr32701696pfb.29.1558471998293;
        Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvzAK0I3jKvrKvk4WFoogERj9U3gR6EcykSO4ArOlDxDZcb3C/2oJk78QU2wPiCFlrCti9
X-Received: by 2002:a62:5306:: with SMTP id h6mr32701599pfb.29.1558471997167;
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558471997; cv=none;
        d=google.com; s=arc-20160816;
        b=sIb5XFchi06QO0/myllXDiWgXM6NebMrf6NKWouvGuwRDne5a8CWBwFdydaaofbJsc
         is+U8JBfNFJH7RC4ywA5T682N+oWg07RA2RCdedfHwXL97RtPT9gm/gloRanUTQNW3Jp
         5owDvnaLXlJcaYh7kwM+09cyYm6R+IEgX/GsC+5xS3xaPVZcN3osLik6ZCLr7TMfpwPY
         uVSJHlc2SQhjXGNYkPvb4BB0WSD93o0LnZmaxKzOQzvBMzzDfIOhCqX/Z2WjaOQHhkou
         gad2lI7/D7Y0C81hXGSJ5X4keB8p422eLMm4PrttQxOHhesdatzIbbz05A7zi29byirK
         VocA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=BLN9Ebt/WutrgbdJ7wJW1gYtlj9nwzx9znYKQRpM/t8=;
        b=uvJs3V3ZJukkseFXAOoiSA+pSAulyrgqCOrfscReFkKfmdGPwnyKkFxQvRbjlXyj+/
         pnAfyf2KkkIYZvydYBmN00mjC5d77VNi+AY4MKzyvWGc3cb7mZ1M5OvLFSe42S6Nu7cz
         Ek3lnQPwW/iOuFQCDy8gohen6K4j7/S+dx9mj9sWC7idURtcq7gwnbOggQlD87HqPj6s
         l4fbn3UfoYpkA3xQhGp/rV2IUhpP+Qny+p7H8FoUZ7bGdPLcaJzYrCk/yXsD/E/4PmhX
         7+tPE5Jbfzzc7Qk1cb/D+hdNLczzWAudOmIu1xiUB1Gphtbw5h/1F+/1RgdtGzfNpL8X
         mXcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 7si24611937pll.99.2019.05.21.13.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 13:53:16 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.91.116])
  by orsmga001.jf.intel.com with ESMTP; 21 May 2019 13:53:16 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 0/2] Fix issues with vmalloc flush flag
Date: Tue, 21 May 2019 13:51:35 -0700
Message-Id: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These two patches address issues with the recently added
VM_FLUSH_RESET_PERMS vmalloc flag.

Patch 1 is the most critical and addresses an issue that could cause a
crash on x86.

Patch 2 addresses an issue where in a rare case strange arguments
could be provided to flush_tlb_kernel_range(). Most arch's should be
fine with it, but some may not like them, so we should avoid doing
this.

v3->v4:
 - Drop patch that switched vm_unmap_alias() calls to regular flush
 - Add patch to address correctness previously fixed in dropped patch

v2->v3:
 - Split into two patches

v1->v2:
 - Update commit message with more detail
 - Fix flush end range on !CONFIG_ARCH_HAS_SET_DIRECT_MAP case

Rick Edgecombe (2):
  vmalloc: Fix calculation of direct map addr range
  vmalloc: Avoid rare case of flushing tlb with weird arguements

 mm/vmalloc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

-- 
2.20.1

