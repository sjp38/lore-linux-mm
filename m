Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 37C196B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 14:25:39 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 6/6] pagemap: introduce data structure for pagemap entry
Date: Mon, 30 Jan 2012 14:27:09 -0500
Message-Id: <1327951629-29381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120130153111.4fefb09a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Jan 30, 2012 at 03:31:11PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 27 Jan 2012 18:02:53 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Currently a local variable of pagemap entry in pagemap_pte_range()
> > is named pfn and typed with u64, but it's not correct (pfn should
> > be unsigned long.)
> > This patch introduces special type for pagemap entry and replace
> > code with it.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  fs/proc/task_mmu.c |   66 +++++++++++++++++++++++++++------------------------
> >  1 files changed, 35 insertions(+), 31 deletions(-)
> > 
> > diff --git 3.3-rc1.orig/fs/proc/task_mmu.c 3.3-rc1/fs/proc/task_mmu.c
> > index e2063d9..c2807a3 100644
> > --- 3.3-rc1.orig/fs/proc/task_mmu.c
> > +++ 3.3-rc1/fs/proc/task_mmu.c
> > @@ -586,9 +586,13 @@ const struct file_operations proc_clear_refs_operations = {
> >  	.llseek		= noop_llseek,
> >  };
> >  
> > +typedef struct {
> > +	u64 pme;
> > +} pme_t;
> > +
> 
> A nitpick..
> 
> How about pagemap_entry_t rather than pme_t ?

OK, I'll use this type name.

> At 1st look, I wondered whether this is a new kind of page table entry type or not ..

We had better avoid this type of confusion if possible.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
