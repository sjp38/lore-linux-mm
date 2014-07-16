Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 15C806B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 23:05:13 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so447585pad.9
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:05:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id os6si13331281pab.9.2014.07.15.20.05.09
        for <linux-mm@kvack.org>;
        Tue, 15 Jul 2014 20:05:10 -0700 (PDT)
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Some RAS bug fix patches
Date: Tue, 15 Jul 2014 22:34:39 -0400
Message-Id: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, bp@alien8.de
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

[PATCH 1/3] APEI, GHES: Cleanup unnecessary function for lock-less
[RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
[PATCH 3/3] RAS, HWPOISON: Fix wrong error recovery status

The patch 1/3 & 3/3 are minor fixes which are irrelevant with patch
2/3. I send them together just to avoid fragments.

The patch 2/3 is a RFC patch depending on the following thread:
https://lkml.org/lkml/2014/6/27/26

Comments and suggestions are welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
