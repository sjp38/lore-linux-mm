Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 355C3440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 03:14:40 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id u9so69631721ykd.1
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 00:14:40 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id m124si7002422ywb.38.2016.02.06.00.14.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Feb 2016 00:14:39 -0800 (PST)
Message-ID: <56B5AB4F.3030809@huawei.com>
Date: Sat, 6 Feb 2016 16:14:07 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Have some confusion about the pfn_valid() ?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>



Hi

In my opinion, pfn_valid() is meant to be able to tell if a given PFN has valid
section, and That section can contain corresponding mem_map. but, the section can
be has holes, the corresponding mem_map also be allcoated, resulting in treating
the PFN as valid incorrect.

what's problem for the interpretation of the above?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
