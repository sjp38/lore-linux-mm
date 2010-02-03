Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 402086B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:39:15 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Message-Id: <201002031039.710275915@firstfloor.org>
Subject: [PATCH] [0/4] SLAB: Fix a couple of slab memory hotadd issues
Date: Wed,  3 Feb 2010 22:39:11 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This fixes various problems in slab found during memory hotadd testing.

All straight forward bug fixes, so could be still .33 candidates.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
