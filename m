Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B9BF56B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 19:16:36 -0400 (EDT)
Date: Tue, 4 Sep 2012 16:16:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v8 PATCH 08/20] memory-hotplug: remove
 /sys/firmware/memmap/X sysfs
Message-Id: <20120904161634.f1f9f693.akpm@linux-foundation.org>
In-Reply-To: <5044454E.7070909@cn.fujitsu.com>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
	<1346148027-24468-9-git-send-email-wency@cn.fujitsu.com>
	<20120831140623.8d13bd2c.akpm@linux-foundation.org>
	<5044454E.7070909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>

On Mon, 03 Sep 2012 13:51:10 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> >> +static void release_firmware_map_entry(struct kobject *kobj)
> >> +{
> >> +	struct firmware_map_entry *entry = to_memmap_entry(kobj);
> >> +	struct page *page;
> >> +
> >> +	page = virt_to_page(entry);
> >> +	if (PageSlab(page) || PageCompound(page))
> > 
> > That PageCompound() test looks rather odd.  Why is this done?
> 
> Liu Jiang and Christoph Lameter discussed how to find slab page
> in this mail:
> https://lkml.org/lkml/2012/7/6/333.

Well, please add a code comment to release_firmware_map_entry() which
fully explains these things.

I see that Christoph and I agree: "It would be cleaner if memory
hotplug had an indicator which allocation mechanism was used and would
use the corresponding free action".  You didn't respond to this
suggestion when he made it, nor when I made it.  What are your thoughts
on this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
