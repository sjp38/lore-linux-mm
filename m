Date: Wed, 30 Jul 2008 01:41:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-Id: <20080730014139.39b3edc5.akpm@linux-foundation.org>
In-Reply-To: <cover.1216928613.git.ebmunson@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Munson <ebmunson@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 12:17:10 -0700 Eric Munson <ebmunson@us.ibm.com> wrote:

> Certain workloads benefit if their data or text segments are backed by
> huge pages. The stack is no exception to this rule but there is no
> mechanism currently that allows the backing of a stack reliably with
> huge pages.  Doing this from userspace is excessively messy and has some
> awkward restrictions.  Particularly on POWER where 256MB of address space
> gets wasted if the stack is setup there.
> 
> This patch stack introduces a personality flag that indicates the kernel
> should setup the stack as a hugetlbfs-backed region. A userspace utility
> may set this flag then exec a process whose stack is to be backed by
> hugetlb pages.
> 
> Eric Munson (5):
>   Align stack boundaries based on personality
>   Add shared and reservation control to hugetlb_file_setup
>   Split boundary checking from body of do_munmap
>   Build hugetlb backed process stacks
>   [PPC] Setup stack memory segment for hugetlb pages
> 
>  arch/powerpc/mm/hugetlbpage.c |    6 +
>  arch/powerpc/mm/slice.c       |   11 ++
>  fs/exec.c                     |  209 ++++++++++++++++++++++++++++++++++++++---
>  fs/hugetlbfs/inode.c          |   52 +++++++----
>  include/asm-powerpc/hugetlb.h |    3 +
>  include/linux/hugetlb.h       |   22 ++++-
>  include/linux/mm.h            |    1 +
>  include/linux/personality.h   |    3 +
>  ipc/shm.c                     |    2 +-
>  mm/mmap.c                     |   11 ++-
>  10 files changed, 284 insertions(+), 36 deletions(-)

That all looks surprisingly straightforward.

Might there exist an x86 port which people can play with?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
