Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2F4BC600385
	for <linux-mm@kvack.org>; Mon, 17 May 2010 12:11:21 -0400 (EDT)
Date: Mon, 17 May 2010 11:06:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mem-hotplug: avoid multiple zones sharing same boot
 strapping boot_pageset
In-Reply-To: <4BF0FC13.4090206@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1005171106150.20764@router.home>
References: <4BF0FC13.4090206@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
