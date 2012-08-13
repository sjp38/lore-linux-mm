Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 9453A6B005D
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:12:51 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 16:42:48 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBCkxK39256086
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 16:42:46 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBCkMM030324
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:12:46 +1000
Message-ID: <5028E12C.70101@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:12:44 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 00/12] thp: optimize use of khugepaged_mutex and dependence
 of CONFIG_NUMA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

khugepaged_mutex is used very complexly and there are too many small pieces
of the code depend on CONFIG_NUMA, they make the code very hardly understand

This patchset try to optimize use of khugepaged_mutex and reduce dependence
of CONFIG_NUMA, after the patchset, the code is more readable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
