Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FDBF6B0011
	for <linux-mm@kvack.org>; Fri,  6 May 2011 21:35:19 -0400 (EDT)
Date: Fri, 6 May 2011 18:35:17 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2011-05-06-16-39 uploaded (fs/proc/task_mmu)
Message-Id: <20110506183517.29369143.rdunlap@xenotime.net>
In-Reply-To: <201105070015.p470FlAR013200@imap1.linux-foundation.org>
References: <201105070015.p470FlAR013200@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Stephen Wilson <wilsons@start.ca>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 06 May 2011 16:39:31 -0700 akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-05-06-16-39 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://zen-kernel.org/kernel/mmotm.git
> 
> It contains the following patches against 2.6.39-rc6:

from "mm-proc-move-show_numa_map-to-fs-proc-task_mmuc.patch":

on i386 (X86_32):

fs/proc/task_mmu.c:981: error: implicit declaration of function 'mpol_to_str'

when CONFIG_SHMEM=n, CONFIG_TMPFS=n, and these NUMA config settings:

CONFIG_X86_NUMAQ=y
CONFIG_X86_SUMMIT_NUMA=y
CONFIG_NUMA=y
# NUMA (Summit) requires SMP, 64GB highmem support, ACPI
CONFIG_AMD_NUMA=y
# CONFIG_NUMA_EMU is not set
CONFIG_USE_PERCPU_NUMA_NODE_ID=y


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
