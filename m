Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m89FCcI8006936
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 11:12:38 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89FCcRA226866
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 11:12:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89FCbZf020465
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 11:12:38 -0400
Subject: Re: [PATCH] Cleanup to make  remove_memory() arch neutral
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080909101703.C099.E1E9C6FF@jp.fujitsu.com>
References: <1220910754.25932.57.camel@badari-desktop>
	 <20080908175621.6dfad0a6.akpm@linux-foundation.org>
	 <20080909101703.C099.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 09 Sep 2008 08:12:52 -0700
Message-Id: <1220973172.25932.68.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, garyhade@us.ibm.com, linux-mm@kvack.org, mel@csn.ul.ie, lcm@us.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-09 at 10:21 +0900, Yasunori Goto wrote:
> > On Mon, 08 Sep 2008 14:52:34 -0700
> > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > 
> > > There is nothing architecture specific about remove_memory().
> > > remove_memory() function is common for all architectures which
> > > support hotplug memory remove. Instead of duplicating it in every
> > > architecture, collapse them into arch neutral function.
> > > 
> > > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > > 
> > >  arch/ia64/mm/init.c   |   17 -----------------
> > >  arch/powerpc/mm/mem.c |   17 -----------------
> > >  arch/s390/mm/init.c   |   11 -----------
> > >  mm/memory_hotplug.c   |   10 ++++++++++
> > >  4 files changed, 10 insertions(+), 45 deletions(-)
> > 
> > I spent some time trying to build-test this on ia64 and gave up.  How
> > the heck do you turn on memory hotplug on ia64?
> > 
> 
> EXPORT_SYMBOL_GPL(remove_memory) is removed.
> It is required by drivers/acpi/acpi_memhotplug.ko.

Thanks for catching it. I forgot that it was being used
by acpi. Since we didn't export it for ppc and s390,
I assumed its safe to remove the export. Sorry !!

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
