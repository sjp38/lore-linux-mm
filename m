Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9VKjGXR004851
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 16:45:16 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VKjAK0111302
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 14:45:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VKjAf8029898
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 14:45:10 -0600
Subject: Re: [PATCH 1/3] Add remove_memory() for ppc64
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
References: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 13:45:02 -0700
Message-Id: <1193863502.6271.38.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 08:49 -0800, Badari Pulavarty wrote:
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int remove_memory(u64 start, u64 size)
> +{
> +	unsigned long start_pfn, end_pfn;
> +	unsigned long timeout = 120 * HZ;
> +	int ret;
> +	start_pfn = start >> PAGE_SHIFT;
> +	end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +	ret = offline_pages(start_pfn, end_pfn, timeout);
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(remove_memory);
> +#endif /* CONFIG_MEMORY_HOTREMOVE */

Did someone go and copy the ia64 verion?  Tsk.  Tsk.  Bad Badari.  :)

Can we just make this a weak symbol in the generic mm/memory_hotplug.c?
Or, make this the generic memory_remove() function int there and have an
arch_remove_memory() hook called from there if the architectures need to
tweak it?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
