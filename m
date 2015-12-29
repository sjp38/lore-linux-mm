Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4116D6B0280
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 04:48:49 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id c192so33426819lfe.2
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 01:48:49 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id r70si11329626lfg.142.2015.12.29.01.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 01:48:48 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id p203so21650963lfa.3
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 01:48:47 -0800 (PST)
Date: Tue, 29 Dec 2015 12:48:44 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
Message-ID: <20151229094844.GN2194@uranus>
References: <20151228211015.GL2194@uranus>
 <20151228151002.0a8e44199d31f7a4fa7fc414@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151228151002.0a8e44199d31f7a4fa7fc414@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 28, 2015 at 03:10:02PM -0800, Andrew Morton wrote:
> On Tue, 29 Dec 2015 00:10:15 +0300 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
...
> 
> This clashes with
> mm-mmapc-remove-redundant-local-variables-for-may_expand_vm.patch,
> below.  I resolved it thusly:
> 
> bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
> {
> 	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
> 		return false;
> 
> 	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
> 				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
> 		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);
> 
> 	return true;
> }

Thanks, Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
