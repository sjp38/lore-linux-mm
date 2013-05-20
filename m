Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id B61786B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 15:55:37 -0400 (EDT)
Message-ID: <1369079733.5673.58.camel@misato.fc.hp.com>
Subject: Re: [PATCH 5/5] ACPI / memhotplug: Drop unnecessary code
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 20 May 2013 13:55:33 -0600
In-Reply-To: <1726699.Z30ifEcQDQ@vostro.rjw.lan>
References: <2250271.rGYN6WlBxf@vostro.rjw.lan>
	 <2228904.eTtCrFuSan@vostro.rjw.lan>
	 <1369070876.5673.51.camel@misato.fc.hp.com>
	 <1726699.Z30ifEcQDQ@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <liuj97@gmail.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-mm@kvack.org

On Mon, 2013-05-20 at 21:47 +0200, Rafael J. Wysocki wrote:
> On Monday, May 20, 2013 11:27:56 AM Toshi Kani wrote:
> > On Sun, 2013-05-19 at 01:34 +0200, Rafael J. Wysocki wrote:
> > > From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

 :

> > > -	lock_memory_hotplug();
> > > -
> > > -	/*
> > > -	 * we have offlined all memory blocks like this:
> > > -	 *   1. lock memory hotplug
> > > -	 *   2. offline a memory block
> > > -	 *   3. unlock memory hotplug
> > > -	 *
> > > -	 * repeat step1-3 to offline the memory block. All memory blocks
> > > -	 * must be offlined before removing memory. But we don't hold the
> > > -	 * lock in the whole operation. So we should check whether all
> > > -	 * memory blocks are offlined.
> > > -	 */
> > > -
> > > -	ret = walk_memory_range(start_pfn, end_pfn, NULL,
> > > -				is_memblock_offlined_cb);
> > > -	if (ret) {
> > > -		unlock_memory_hotplug();
> > > -		return ret;
> > > -	}
> > > -
> > 
> > I think the above procedure is still useful for safe guard.
> 
> But then it shoud to BUG_ON() instead of returning an error (which isn't very
> useful for anything now).

Right since we cannot fail at that state.

> > > -	/* remove memmap entry */
> > > -	firmware_map_remove(start, start + size, "System RAM");
> > > -
> > > -	arch_remove_memory(start, size);
> > > -
> > > -	try_offline_node(nid);
> > 
> > The above procedure performs memory hot-delete specific operations and
> > is necessary.
> 
> OK, I see.  I'll replace this patch with something simpler, then.

Thanks.

> What about the other patches in the series?

I will send you my comments later (a bit interrupted for other thing
now).  

-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
