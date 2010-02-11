Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9829E6B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:54:04 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Message-Id: <20100211953.850854588@firstfloor.org>
Subject: [PATCH] [0/4] Update slab memory hotplug series
Date: Thu, 11 Feb 2010 21:53:59 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>


Should address all earlier comments (except for the funny cpuset
case which I chose to declare a don't do that)

Also this time hopefully without missing patches.

There are still some other issues with memory hotadd, but that's the 
current slab set.

The patches are against 2.6.32, but apply to mainline I believe.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
