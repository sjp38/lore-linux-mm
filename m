Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6379E6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:49:48 -0400 (EDT)
From: Robin Holt <holt@sgi.com>
Message-Id: <20091015223959.783988000@alcatraz.americas.sgi.com>
Date: Thu, 15 Oct 2009 17:39:59 -0500
Subject: [patch 0/2] x86, UV: fixups for configurations with a large number of nodes.
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>


We need the __uv_hub_info structure to contain the correct values for
n_val, gpa_mask, and lowmem_remap_*.  The first patch in the series
accomplishes this.   Could this be included in the stable tree as well.
Without this patch, booting a large configuration hits a problem where
the upper bits of the gnode affect the pnode and the bau will not operate.

The second patch cleans up the broadcast assist unit code a small bit.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
