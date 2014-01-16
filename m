Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE246B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:27:27 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so1139034eaj.7
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 05:27:26 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id j47si504728eeo.221.2014.01.16.05.27.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 05:27:26 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Thu, 16 Jan 2014 13:27:25 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id A985A1B0805F
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:26:44 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0GDR95266846868
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:27:09 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0GDRKwY001432
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 06:27:21 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V4 0/2] mm/memblock: Excluded memory
Date: Thu, 16 Jan 2014 14:27:05 +0100
Message-Id: <1389878827-7827-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, grygorii.strashko@ti.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com

Here is a new version of the memblock.nomap patch.

This time without the first patch (that has already been taken by akpm).

The second patch is now split into the functional part (Add support...)
and the cleanup/refactoring part. This has been done for clarity as
announced before.

Philipp Hachtmann (2):
  mm/memblock: Add support for excluded memory areas
  mm/memblock: Cleanup and refactoring after addition of nomap

 include/linux/memblock.h |  57 +++++++++---
 mm/Kconfig               |   3 +
 mm/memblock.c            | 233 +++++++++++++++++++++++++++++++++++------------
 mm/nobootmem.c           |   9 ++
 4 files changed, 231 insertions(+), 71 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
