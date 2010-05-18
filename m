Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E37D46004B1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 09:55:50 -0400 (EDT)
Date: Tue, 18 May 2010 08:55:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND][PATCH 3/3] mem-hotplug: fix potential race while building
 zonelist for new populated zone
In-Reply-To: <4BF257BA.7020507@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1005180853400.15028@router.home>
References: <4BF0FC4C.4060306@linux.intel.com> <alpine.DEB.2.00.1005171108070.20764@router.home> <20100518021923.GA6595@localhost> <4BF257BA.7020507@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 May 2010, Haicheng Li wrote:

> +extern struct mutex zonelists_pageset_mutex;

The mutext is used for multiple serializations having to do with zones.
"pageset" suggests its only for pagesets.

So

	zones_mutex?

or

	zonelists_mutex?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
