Date: Wed, 21 May 2008 21:24:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
 control (v5)
Message-Id: <20080521212408.6f535259.akpm@linux-foundation.org>
In-Reply-To: <20080521153012.15001.96490.sendpatchset@localhost.localdomain>
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
	<20080521153012.15001.96490.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 21:00:12 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> This patch adds support for accounting and control of virtual address space
> limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
> The core of the accounting takes place during fork time in copy_process(),
> may_expand_vm(), remove_vma_list() and exit_mmap(). 
> 
> Changelog v5->v4
> 
> Move specific hooks in code to insert_vm_struct
> Use mmap_sem to protect mm->owner from changing and mm->owner from
> changing cgroups.
> 
> ...
>
> + * brk(), sbrk()), stack expansion, mremap(), etc - called with
> + * mmap_sem held.
> + * decreasing - called with mmap_sem held.
> + * This callback is called with mmap_sem held

It's good to document the locking prerequisites but for rwsems, one
should specify whether it must be held for reading or for writing.

Of course, down_write() is a superset of down_read(), so if it's "held
for reading" then either mode-of-holding is OK.  But it's best to spell
all that out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
