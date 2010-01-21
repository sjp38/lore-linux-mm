Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 335246B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 00:49:38 -0500 (EST)
Date: Thu, 21 Jan 2010 13:49:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Message-ID: <20100121054932.GD24236@localhost>
References: <20100113135305.013124116@intel.com> <20100113135957.833222772@intel.com> <20100114124526.GB7518@laptop> <20100118133512.GC721@localhost> <20100118142359.GA14472@laptop> <20100119013303.GA12513@localhost> <20100119112343.04f4eff5.kamezawa.hiroyu@jp.fujitsu.com> <20100121050521.GB24236@localhost> <20100121142106.c13c2bbf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20100121142106.c13c2bbf.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 20, 2010 at 10:21:06PM -0700, KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Jan 2010 13:05:21 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Mon, Jan 18, 2010 at 07:23:43PM -0700, KAMEZAWA Hiroyuki wrote:

> > I did some audit and find that
> > 
> > - set_memory_uc(), set_memory_array_uc(), set_pages_uc(),
> >   set_pages_array_uc() are called EFI code and various video drivers,
> >   all of them don't touch HIGHMEM RAM
> > 
> > - Kame: ioremap() won't allow remap of physical RAM
> > 
> > So kmap_atomic() is safe.  Let's just settle on this patch?
> > 
> I recommend you to keep check on VM_IOREMAP. That was checked far before
> I started to see Linux. Some _unknown_ driver can call get_vm_area() and
> map arbitrary pages there.

OK, I'll turn this patch into a less radical one.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
