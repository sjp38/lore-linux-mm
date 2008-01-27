Date: Sat, 26 Jan 2008 22:03:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix procfs task exe symlink
Message-Id: <20080126220336.a2a3caf7.akpm@linux-foundation.org>
In-Reply-To: <1201112977.5443.29.camel@localhost.localdomain>
References: <1201112977.5443.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@ftp.linux.org.uk, dhowells@redhat.com, wtaber@us.ibm.com, owilliam@br.ibm.com, rkissel@us.ibm.com, hch@lst.de
List-ID: <linux-mm.kvack.org>

> On Wed, 23 Jan 2008 10:29:37 -0800 Matt Helsley <matthltc@us.ibm.com> wrote:
> 
> Andrew, please consider this patch for inclusion in -mm.
> 
> ...
>

Can't say that we're particularly exercised about mvfs's problems, but the
current way of doing /proc/pid/exe is indeed a nasty hack.

> 
>  fs/binfmt_flat.c          |    3 +
>  fs/exec.c                 |    2 +
>  fs/proc/base.c            |   77 ++++++++++++++++++++++++++++++++++++++++++++++
>  fs/proc/internal.h        |    1 
>  fs/proc/task_mmu.c        |   34 --------------------
>  fs/proc/task_nommu.c      |   34 --------------------
>  include/linux/init_task.h |    8 ++++
>  include/linux/mm.h        |   22 +++++++++++++
>  include/linux/mm_types.h  |    7 ++++
>  include/linux/proc_fs.h   |   14 +++++++-
>  kernel/fork.c             |    3 +
>  mm/mmap.c                 |   22 ++++++++++---
>  mm/nommu.c                |   15 +++++++-
>  13 files changed, 164 insertions(+), 78 deletions(-)

It's a fairly expensive fix though.  Can't we just do a strcpy() somewhere
at exec time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
