Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09EBF6B002A
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 04:02:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f15so7600367wmd.1
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 01:02:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f28sor7708358edd.4.2018.02.15.01.02.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 01:02:48 -0800 (PST)
Date: Thu, 15 Feb 2018 12:02:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [bug?] mallocstress poor performance with THP on arm64 system
Message-ID: <20180215090246.qrsnncq3ajtbdlfy@node.shutemov.name>
References: <1523287676.1950020.1518648233654.JavaMail.zimbra@redhat.com>
 <1847959563.1954032.1518649501357.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1847959563.1954032.1518649501357.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lwoodman <lwoodman@redhat.com>, Rafael Aquini <aquini@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Feb 14, 2018 at 06:05:01PM -0500, Jan Stancek wrote:
> Hi,
> 
> mallocstress[1] LTP testcase takes ~5+ minutes to complete
> on some arm64 systems (e.g. 4 node, 64 CPU, 256GB RAM):
>  real    7m58.089s
>  user    0m0.513s
>  sys     24m27.041s
> 
> But if I turn off THP ("transparent_hugepage=never") it's a lot faster:
>  real    0m4.185s
>  user    0m0.298s
>  sys     0m13.954s
> 

It's multi-threaded workload. My *guess* is that poor performance is due
to lack of ARCH_ENABLE_SPLIT_PMD_PTLOCK support on arm64.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
