Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF7D6B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 01:07:19 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so139208bkb.16
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 22:07:18 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id pf10si16629198bkb.249.2014.01.27.22.07.16
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 22:07:18 -0800 (PST)
Date: Tue, 28 Jan 2014 17:06:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Message-ID: <20140128060652.GZ13997@dastard>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
 <20140123090133.GR13997@dastard>
 <100D68C7BA14664A8938383216E40DE04061DF33@FMSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <100D68C7BA14664A8938383216E40DE04061DF33@FMSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Thu, Jan 23, 2014 at 12:12:43PM +0000, Wilcox, Matthew R wrote:
> Are you hitting the same problems with ext4 fsck that we did?  Version 1.42.8 reports spurious corruption.  From the 1.42.9 changelog:
> 
>   * Fixed a regression introduced in 1.42.8 which would cause e2fsck to
>     erroneously report uninitialized extents past i_size to be invalid.

Don't think so - I'm running 1.42.9 on my test VM.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
