Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4105682F65
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 11:08:43 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so30680826pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 08:08:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id a6si3186399pbu.198.2015.10.09.08.08.42
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 08:08:42 -0700 (PDT)
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com>
 <5617989E.9070700@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5617D878.5060903@intel.com>
Date: Fri, 9 Oct 2015 08:08:40 -0700
MIME-Version: 1.0
In-Reply-To: <5617989E.9070700@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, mel@csn.ul.ie, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, zhongjiang@huawei.com

On 10/09/2015 03:36 AM, Xishi Qiu wrote:
> I mean the mirrored region can not at the middle or end of the zone,
> BIOS should report the memory like this, 
> 
> e.g.
> BIOS
> node0: 0-4G mirrored, 4-8G mirrored, 8-16G non-mirrored
> node1: 16-24G mirrored, 24-32G non-mirrored
> 
> OS
> node0: DMA DMA32 are both mirrored, NORMAL(4-8G), MOVABLE(8-16G)
> node1: NORMAL(16-24G), MOVABLE(24-32G)

I understand if the mirrored regions are always at the start of the zone
today, but is that somehow guaranteed going forward on all future hardware?

I think it's important to at least consider what we would do if DMA32
turned out to be non-reliable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
