Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9039C8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 15:47:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g9-v6so1410443pgc.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:47:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g16-v6si1902825pgj.35.2018.09.12.12.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 12:47:29 -0700 (PDT)
Date: Wed, 12 Sep 2018 12:47:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 201085] New: Kernel allows mlock() on pages in CMA without
 migrating pages out of CMA first
Message-Id: <20180912124727.fccccf432d2d8163ead79288@linux-foundation.org>
In-Reply-To: <bug-201085-27@https.bugzilla.kernel.org/>
References: <bug-201085-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>
Cc: bugzilla-daemon@bugzilla.kernel.org, tpearson@raptorengineering.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 11 Sep 2018 03:59:11 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=201085
> 
>             Bug ID: 201085
>            Summary: Kernel allows mlock() on pages in CMA without
>                     migrating pages out of CMA first
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.18
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: tpearson@raptorengineering.com
>         Regression: No
> 
> Pages allocated in CMA are not migrated out of CMA when non-CMA memory is
> available and locking is attempted via mlock().  This can result in rapid
> exhaustion of the CMA pool if memory locking is used by an application with
> large memory requirements such as QEMU.
> 
> To reproduce, on a dual-CPU (NUMA) POWER9 host try to launch a VM with mlock=on
> and 1/2 or more of physical memory allocated to the guest.  Observe full CMA
> pool depletion occurs despite plenty of normal free RAM available.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
