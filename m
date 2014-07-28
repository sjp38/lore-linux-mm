Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4936B0038
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 03:22:18 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so9462957pdj.1
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 00:22:17 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bc15si8454933pdb.146.2014.07.28.00.22.16
        for <linux-mm@kvack.org>;
        Mon, 28 Jul 2014 00:22:17 -0700 (PDT)
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: two minor update patches for RAS
Date: Mon, 28 Jul 2014 02:50:58 -0400
Message-Id: <1406530260-26078-1-git-send-email-gong.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@intel.com, n-horiguchi@ah.jp.nec.com, bp@alien8.de
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org

[PATCH 1/2] APEI, GHES: Cleanup unnecessary function for lock-less
[PATCH 2/2] RAS, HWPOISON: Fix wrong error recovery status

These two patches are trivial fixes for APEI and HWPOISON.
Send them together to avoid fragments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
