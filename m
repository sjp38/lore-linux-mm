Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB6956B0492
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 16:48:42 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c18-v6so6038320plz.22
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 13:48:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m16-v6si47547689pgd.48.2018.11.06.13.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 13:48:40 -0800 (PST)
Date: Tue, 6 Nov 2018 13:48:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 201603] New: NULL pointer dereference when using z3fold
 and zswap
Message-Id: <20181106134837.014c0bf61eb959e27f5edd0c@linux-foundation.org>
In-Reply-To: <bug-201603-27@https.bugzilla.kernel.org/>
References: <bug-201603-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, jagannathante@gmail.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 02 Nov 2018 10:41:46 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=201603
> 
>             Bug ID: 201603
>            Summary: NULL pointer dereference when using z3fold and zswap
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.18.16
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: jagannathante@gmail.com
>         Regression: No
> 
> Created attachment 279297
>   --> https://bugzilla.kernel.org/attachment.cgi?id=279297&action=edit
> dmesg log of crash
> 
> This happens mostly during memory pressure but I am not sure how to trigger it
> reliably. I am attaching the full log.
> 
> This is the kernel commandline
> 
> >BOOT_IMAGE=../vmlinuz-linux root=UUID=57274b3a-92ab-468e-b03a-06026675c1af rw
> >rd.luks.name=92b4aeb2-fb97-45c1-8a60-2816efe5d57e=home resume=/dev/mapper/home
> >resume_offset=42772480 acpi_backlight=video zswap.enabled=1 zswap.zpool=z3fold
> >zswap.max_pool_percent=5 transparent_hugepage=madvise scsi_mod.use_blk_mq=1
> >vga=current initrd=../intel-ucode.img,../initramfs-linux.img
> 
> I found this bug https://bugzilla.kernel.org/show_bug.cgi?id=198585 to be very
> similar but the proposed fix has not been merged so I can't be sure if it will
> fix the issue I am having.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
