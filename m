Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B36F56B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 16:15:25 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so58284138pab.2
        for <linux-mm@kvack.org>; Fri, 08 May 2015 13:15:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x10si8399179pdr.182.2015.05.08.13.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 13:15:24 -0700 (PDT)
Date: Fri, 8 May 2015 13:15:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-Id: <20150508131523.f970d13a213bca63bd6f2619@linux-foundation.org>
In-Reply-To: <20150508200610.GB29933@akamai.com>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
	<20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
	<20150508200610.GB29933@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Fri, 8 May 2015 16:06:10 -0400 Eric B Munson <emunson@akamai.com> wrote:

> On Fri, 08 May 2015, Andrew Morton wrote:
> 
> > On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.com> wrote:
> > 
> > > mlock() allows a user to control page out of program memory, but this
> > > comes at the cost of faulting in the entire mapping when it is
> > > allocated.  For large mappings where the entire area is not necessary
> > > this is not ideal.
> > > 
> > > This series introduces new flags for mmap() and mlockall() that allow a
> > > user to specify that the covered are should not be paged out, but only
> > > after the memory has been used the first time.
> > 
> > Please tell us much much more about the value of these changes: the use
> > cases, the behavioural improvements and performance results which the
> > patchset brings to those use cases, etc.
> > 
> 
> The primary use case is for mmaping large files read only.  The process
> knows that some of the data is necessary, but it is unlikely that the
> entire file will be needed.  The developer only wants to pay the cost to
> read the data in once.  Unfortunately developer must choose between
> allowing the kernel to page in the memory as needed and guaranteeing
> that the data will only be read from disk once.  The first option runs
> the risk of having the memory reclaimed if the system is under memory
> pressure, the second forces the memory usage and startup delay when
> faulting in the entire file.

Why can't the application mmap only those parts of the file which it
wants and mlock those?

> I am working on getting startup times with and without this change for
> an application, I will post them as soon as I have them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
