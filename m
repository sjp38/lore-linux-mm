Date: Thu, 3 Jul 2008 00:04:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm] BUG: sleeping function called from invalid context at
 include/linux/pagemap.h:290
Message-Id: <20080703000444.2463eee9.akpm@linux-foundation.org>
In-Reply-To: <486C74B1.3000007@cn.fujitsu.com>
References: <486C74B1.3000007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik Van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 03 Jul 2008 14:41:53 +0800 Li Zefan <lizf@cn.fujitsu.com> wrote:

> Seems the problematic patch is :
> mmap-handle-mlocked-pages-during-map-remap-unmap.patch
> 
> I'm using mmotm uploaded yesterday by Andrew, so I guess this bug
> has not been fixed ?

Not as far as I know.  And I can't immediately spot the bug there.

> BUG: sleeping function called from invalid context at include/linux/pagemap.h:290
> in_atomic():1, irqs_disabled():0
> no locks held by gpg-agent/2134.
> Pid: 2134, comm: gpg-agent Not tainted 2.6.26-rc8-mm1 #11
>  [<c0421d38>] __might_sleep+0xbe/0xc5
>  [<c04770a2>] __munlock_pte_handler+0x3c/0x9e
>  [<c047c11f>] walk_page_range+0x15b/0x1b4
>  [<c0477048>] __munlock_vma_pages_range+0x4e/0x5b
>  [<c0476f0c>] ? __munlock_pmd_handler+0x0/0x10
>  [<c0477066>] ? __munlock_pte_handler+0x0/0x9e
>  [<c0477064>] munlock_vma_pages_range+0xf/0x11
>  [<c0477dcb>] exit_mmap+0x32/0xf2
>  [<c042ac12>] ? exit_mm+0xc7/0xda
>  [<c042732a>] mmput+0x3a/0x8b
>  [<c042ac20>] exit_mm+0xd5/0xda
>  [<c042bf6a>] do_exit+0x1fb/0x5d5
>  [<c045c4df>] ? audit_syscall_exit+0x2aa/0x2c5
>  [<c042c3a3>] do_group_exit+0x5f/0x88
>  [<c042c3db>] sys_exit_group+0xf/0x11
>  [<c0403956>] syscall_call+0x7/0xb
>  =======================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
