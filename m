Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2726B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 17:55:30 -0400 (EDT)
Date: Thu, 21 Jul 2011 14:54:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Cross Memory Attach v3
Message-Id: <20110721145433.a77818b2.akpm@linux-foundation.org>
In-Reply-To: <20110719003537.16b189ae@lilo>
References: <20110719003537.16b189ae@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, linux-arch@vger.kernel.org

On Tue, 19 Jul 2011 00:35:37 +0930
Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> Hi Andrew,
> 
> Resending with CC's as you requested. Have added information about a man
> page and what is required for arches other than x86 and powerpc which
> have already been done.
> 
> Just as a reminder of what has happened so far, repeating some content
> from previous emails about it:
> 
> The basic idea behind cross memory attach is to allow MPI programs doing
> intra-node communication to do a single copy of the message rather than
> a double copy of the message via shared memory.
> 
> The following patch attempts to achieve this by allowing a
> destination process, given an address and size from a source process, to
> copy memory directly from the source process into its own address space
> via a system call. There is also a symmetrical ability to copy from 
> the current process's address space into a destination process's
> address space.
>
> ...
>
>  arch/powerpc/include/asm/systbl.h  |    2 
>  arch/powerpc/include/asm/unistd.h  |    4 
>  arch/x86/include/asm/unistd_32.h   |    4 
>  arch/x86/kernel/syscall_table_32.S |    2 
>  fs/aio.c                           |    4 
>  fs/compat.c                        |    7 
>  fs/read_write.c                    |    8 
>  include/linux/compat.h             |    3 
>  include/linux/fs.h                 |    7 
>  include/linux/syscalls.h           |   13 +
>  mm/Makefile                        |    3 
>  mm/process_vm_access.c             |  446 +++++++++++++++++++++++++++++++++++++
>  security/keys/compat.c             |    2 
>  security/keys/keyctl.c             |    2 
>  14 files changed, 490 insertions(+), 17 deletions(-)

Confused.  Why no arch/x86/include/asm/unistd_64.h wire-up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
