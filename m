Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 547206B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:20:01 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so80231010pad.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:20:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id m2si49177328paw.225.2016.08.10.09.20.00
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:20:00 -0700 (PDT)
Subject: Re: [QUESTION] mmap of device file with huge pages
References: <85d8c7bb8bcc4a30865a4512dd174cf8@IL-EXCH02.marvell.com>
 <57AA155B.70009@intel.com>
 <ca84d8e02a0942c39ad0da01a1fe43f1@IL-EXCH02.marvell.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57AB5430.5000305@intel.com>
Date: Wed, 10 Aug 2016 09:20:00 -0700
MIME-Version: 1.0
In-Reply-To: <ca84d8e02a0942c39ad0da01a1fe43f1@IL-EXCH02.marvell.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yehuda Yitschak <yehuday@marvell.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Shadi Ammouri <shadi@marvell.com>

On 08/10/2016 12:36 AM, Yehuda Yitschak wrote:
>>> But, the thing I generally suggest is that you
>>> allocate hugetlbfs memory or anonymous transparent huge pages in
>>> your applciation via the _normal_ mechanisms, and then hand a
>>> pointer to that in to your driver.
> Thanks. I can try that. Once I hand the pointer to the driver, is
> there a standard API to map user-space memory to kernel space.

Yes.  It's probably worth reading:

http://www.oreilly.com/openbook/linuxdrive3/book/ch15.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
