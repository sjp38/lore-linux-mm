Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1244B6B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 11:44:28 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id kr7so93388456pab.5
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 08:44:28 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d4si22908728pfd.152.2016.11.14.08.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 08:44:27 -0800 (PST)
Subject: Re: [PATCH] mm/pkeys: generate pkey system call code only if
 ARCH_HAS_PKEYS is selected
References: <20161114111251.70084-1-heiko.carstens@de.ibm.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <8d880fbe-5a20-c027-4c8f-8a464d81dcbb@linux.intel.com>
Date: Mon, 14 Nov 2016 08:44:24 -0800
MIME-Version: 1.0
In-Reply-To: <20161114111251.70084-1-heiko.carstens@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>

On 11/14/2016 03:12 AM, Heiko Carstens wrote:
> Having code for the pkey_mprotect, pkey_alloc and pkey_free system
> calls makes only sense if ARCH_HAS_PKEYS is selected. If not selected
> these system calls will always return -ENOSPC or -EINVAL.
> 
> To simplify things and have less code generate the pkey system call
> code only if ARCH_HAS_PKEYS is selected.
> 
> For architectures which have already wired up the system calls, but do
> not select ARCH_HAS_PKEYS this will result in less generated code and
> a different return code: the three system calls will now always return
> -ENOSYS, using the cond_syscall mechanism.
> 
> For architectures which have not wired up the system calls less
> unreachable code will be generated.
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

This is fine with me.  FWIW:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
