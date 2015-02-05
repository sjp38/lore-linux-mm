Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9029B828FD
	for <linux-mm@kvack.org>; Thu,  5 Feb 2015 15:25:55 -0500 (EST)
Received: by pdjg10 with SMTP id g10so3709742pdj.1
        for <linux-mm@kvack.org>; Thu, 05 Feb 2015 12:25:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mw8si7377837pdb.253.2015.02.05.12.25.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 12:25:54 -0800 (PST)
Date: Thu, 5 Feb 2015 12:25:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_page'
Message-Id: <20150205122552.1485c1439ec6c019e9443c51@linux-foundation.org>
In-Reply-To: <100D68C7BA14664A8938383216E40DE040856952@FMSMSX114.amr.corp.intel.com>
References: <201501221315.sbz4rdsB%fengguang.wu@intel.com>
	<100D68C7BA14664A8938383216E40DE040853FB4@FMSMSX114.amr.corp.intel.com>
	<20150205122115.8fe1037870b76d75afc3fb03@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE040856952@FMSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>

On Thu, 5 Feb 2015 20:22:34 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:

> 
> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org] 
> Sent: Thursday, February 05, 2015 12:21 PM
> To: Wilcox, Matthew R
> Cc: Wu, Fengguang; kbuild-all@01.org; Linux Memory Management List; linux-mips@linux-mips.org; linux-arm-kernel@lists.arm.linux.org.uk
> Subject: Re: [next:master 4658/4676] undefined reference to `copy_user_page'
> 
> On Thu, 22 Jan 2015 15:12:15 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:
> 
> > Looks like mips *declares* copy_user_page(), but never *defines* an implementation.
> > 
> > It's documented in Documentation/cachetlb.txt, but it's not (currently) called if the architecture defines its own copy_user_highpage(), so some bitrot has occurred.  ARM is currently fixing this, and MIPS will need to do the same.
> > 
> > (We can't use copy_user_highpage() in DAX because we don't necessarily have a struct page for 'from'.)
> 
> > Has there been any progress on this?  It would be unpleasant to merge
> > DAX into 3.19 and break MIPS and ARM.
>
> Yes, both MIPS and ARM have sent patches out for this.

I'm not seeing either in linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
