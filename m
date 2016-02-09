Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 657166B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 15:20:17 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so96506345pac.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 12:20:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y4si29318646par.45.2016.02.09.12.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 12:20:16 -0800 (PST)
Date: Tue, 9 Feb 2016 12:20:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 112211] New: ATI Radeon Graphics not rendering correctly
Message-Id: <20160209122015.71a63bd2d7ee34599fb79e9e@linux-foundation.org>
In-Reply-To: <bug-112211-27@https.bugzilla.kernel.org/>
References: <bug-112211-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: smf.linux@ntlworld.com
Cc: bugzilla-daemon@bugzilla.kernel.org, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 09 Feb 2016 08:41:39 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=112211
> 
>             Bug ID: 112211
>            Summary: ATI Radeon Graphics not rendering correctly
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: Linux 4.5-rc3
>           Hardware: IA-32
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: smf.linux@ntlworld.com
>         Regression: No
> 
> On testing linux 4.5-rc( 1,2 and 3) I have found that my display is not
> rendered correctly on starting the X server. My screen is mainly black with
> portions of the desktop appearing from time to time. I initially raised this
> with the DRM/Radeon team:
> 
> https://bugs.freedesktop.org/show_bug.cgi?id=93998
> 
> On investigation a bisect identified the following commit as the source of my
> problem:
> 
> 01c8f1c44b83a0825b573e7c723b033cece37b86 is the first bad commit
> commit 01c8f1c44b83a0825b573e7c723b033cece37b86
> Author: Dan Williams <dan.j.williams@intel.com>
> Date:   Fri Jan 15 16:56:40 2016 -0800
> 
>     mm, dax, gpu: convert vm_insert_mixed to pfn_t
> 
>     Convert the raw unsigned long 'pfn' argument to pfn_t for the purpose of
>     evaluating the PFN_MAP and PFN_DEV flags.  When both are set it triggers
>     _PAGE_DEVMAP to be set in the resulting pte.
> 
>     There are no functional changes to the gpu drivers as a result of this
>     conversion.
> 
>     Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>     Cc: Dave Hansen <dave@sr71.net>
>     Cc: David Airlie <airlied@linux.ie>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> The problem is present on two AMD/ATI systems I have tried but is absent from
> my Intel based laptop. All my systems are 32 bit LFS builds.
> 
> I did try to contact Dan Williams but I am not sure that my e-mail got through,
> can anyone suggest a way forward please ?
> 

Does your kernel include

commit 03fc2da63b9a33dce784a2075c7e068bb97cbf69
Author: Dan Williams <dan.j.williams@intel.com>
Date:   Tue Jan 26 09:48:05 2016 -0800

    mm: fix pfn_t to page conversion in vm_insert_mixed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
