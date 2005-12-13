Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBDGnbwr029707
	for <linux-mm@kvack.org>; Tue, 13 Dec 2005 11:49:37 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBDGpDkD067578
	for <linux-mm@kvack.org>; Tue, 13 Dec 2005 09:51:16 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBDGnYMV020835
	for <linux-mm@kvack.org>; Tue, 13 Dec 2005 09:49:34 -0700
Subject: Re: [Patch] Fix calculation of grow_pgdat_span() in
	mm/memory_hotplug.c
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051213220842.9C02.Y-GOTO@jp.fujitsu.com>
References: <20051213220842.9C02.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 13 Dec 2005 08:49:26 -0800
Message-Id: <1134492566.6448.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-12-13 at 22:20 +0900, Yasunori Goto wrote:
> Dave-san.
> CC: Andrew-san.
> 
> I realized 2.6.15-rc5 still has a bug for memory hotplug.
> The calculation for node_spanned_pages at grow_pgdat_span() is
> clearly wrong. This is patch for it.

Clearly wrong is the term for it.  Thanks for the fix.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
