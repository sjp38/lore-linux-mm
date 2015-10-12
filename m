Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 03A966B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:32:39 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so144372884wic.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:32:38 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id un4si6277551wjc.206.2015.10.12.03.32.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 03:32:37 -0700 (PDT)
Received: by wieq12 with SMTP id q12so13405408wie.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:32:37 -0700 (PDT)
Date: Mon, 12 Oct 2015 11:32:35 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
Message-ID: <20151012103235.GB2579@codeblueprint.co.uk>
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com>
 <561787DA.4040809@jp.fujitsu.com>
 <5617989E.9070700@huawei.com>
 <5617D878.5060903@intel.com>
 <3908561D78D1C84285E8C5FCA982C28F32B523DB@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B523DB@ORSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, "zhongjiang@huawei.com" <zhongjiang@huawei.com>

On Fri, 09 Oct, at 06:51:34PM, Luck, Tony wrote:
> 
> Current hardware can map one mirrored region from each memory controller.
> We have two memory controllers per socket.  So on a 4-socket machine we will
> usually have 8 separate mirrored ranges. Two per NUMA node (assuming
> cluster on die is not enabled).
> 
> Practically I think it is safe to assume that any sane configuration will always
> choose to mirror the <4GB range:
> 
> 1) It's a trivial percentage of total memory on a system that supports mirror
> (2GB[1] out of my, essentially minimal, 512GB[2] machine). So 0.4% ... why would
> you not mirror it?
> 2) It contains a bunch of things that you are likely to want mirrored. Currently
> our boot loaders put the kernel there (don't they??). All sorts of BIOS space that
> might be accessed at any time by SMI is there.

Yeah, the bootloader and kernel image will most likely be in < 4GB
region. That's not a hard requirement, and there's certainly support
for loading things at higher addresses, but this low region is
currently still preferred (see CONFIG_PHYSICAL_START).

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
