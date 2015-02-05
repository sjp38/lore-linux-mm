Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D7666828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:21:17 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kq14so4613300pab.11
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:21:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id am3si3232732pbc.108.2015.02.05.12.21.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 12:21:16 -0800 (PST)
Date: Thu, 5 Feb 2015 12:21:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_page'
Message-Id: <20150205122115.8fe1037870b76d75afc3fb03@linux-foundation.org>
In-Reply-To: <100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
References: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
	<100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, linux-arm-kernel@lists.arm.linux.org.uk

On Thu, 22 Jan 2015 15:12:15 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:

> Looks like mips *declares* copy_user_page(), but never *defines* an implementation.
> 
> It's documented in Documentation/cachetlb.txt, but it's not (currently) called if the architecture defines its own copy_user_highpage(), so some bitrot has occurred.  ARM is currently fixing this, and MIPS will need to do the same.
> 
> (We can't use copy_user_highpage() in DAX because we don't necessarily have a struct page for 'from'.)

Has there been any progress on this?  It would be unpleasant to merge
DAX into 3.19 and break MIPS and ARM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
