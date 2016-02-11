Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BD4BF6B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 16:30:28 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id e127so35615660pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:30:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sb2si14836060pac.161.2016.02.11.13.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 13:30:28 -0800 (PST)
Date: Thu, 11 Feb 2016 13:30:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 112301] New: [bisected] NULL pointer dereference when
 starting a kvm based VM
Message-Id: <20160211133026.96452d486f8029084c4129b7@linux-foundation.org>
In-Reply-To: <bug-112301-27@https.bugzilla.kernel.org/>
References: <bug-112301-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: harn-solo@gmx.de
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, ebru.akagunduz@gmail.com, Hugh Dickins <hughd@google.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 11 Feb 2016 07:09:04 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=112301
> 
>             Bug ID: 112301
>            Summary: [bisected] NULL pointer dereference when starting a
>                     kvm based VM
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.5-rcX
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: harn-solo@gmx.de
>         Regression: No
> 
> Created attachment 203451
>   --> https://bugzilla.kernel.org/attachment.cgi?id=203451&action=edit
> Call Trace of a NULL pointer dereference at gup_pte_range
> 
> Starting a qemu-kvm based VM configured to use hughpages I'm getting the
> following NULL pointer dereference, see attached dmesg section.
> 
> The issue was introduced with commit 7d2eba0557c18f7522b98befed98799990dd4fdb
> Author: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> Date:   Thu Jan 14 15:22:19 2016 -0800
>     mm: add tracepoint for scanning pages

Thanks for the detailed report.  Can you please verify that your tree
has 629d9d1cafbd49cb374 ("mm: avoid uninitialized variable in
tracepoint")?

vfio_pin_pages() doesn't seem to be doing anything crazy.  Hugh, Ebru:
could you please take a look?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
