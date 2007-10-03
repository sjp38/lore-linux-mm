Date: Thu, 4 Oct 2007 01:25:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] PPC64 Exporting memory information through /proc/iomem
Message-Id: <20071004012547.42c457b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1191425735.6106.76.camel@dyn9047017100.beaverton.ibm.com>
References: <1191346196.6106.20.camel@dyn9047017100.beaverton.ibm.com>
	<18178.52359.953289.638736@cargo.ozlabs.ibm.com>
	<1191366653.6106.68.camel@dyn9047017100.beaverton.ibm.com>
	<20071003101954.52308f22.kamezawa.hiroyu@jp.fujitsu.com>
	<1191425735.6106.76.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: paulus@samba.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, anton@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 03 Oct 2007 08:35:35 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Wed, 2007-10-03 at 10:19 +0900, KAMEZAWA Hiroyuki wrote:
> CONFIG_ARCH_HAS_VALID_MEMORY_RANGE. Then define own
> find_next_system_ram() (rename to is_valid_memory_range()) - which
> checks the given range is a valid memory range for memory-remove
> or not. What do you think ?
> 
My concern is...
Now, memory hot *add* makes use of resource(/proc/iomem) information for onlining
memory.(See add_memory()->register_memory_resource() in mm/memoryhotplug.c)
So, we'll have to consider changing it if we need.

Does PPC64 memory hot add registers new memory information to arch dependent
information list ? It seems ppc64 registers hot-added memory information from
*probe* file and registers it by add_memory()->register_memory_resource().

If you add all add/remove/walk system ram information in sane way, I have no
objection.

I like find_next_system_ram() because I used some amount of time to debug it ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
