Date: Wed, 3 Oct 2007 10:31:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-Id: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

Now, SYSTEM_RAM is registerd to resouce list and a user can see memory map
from /proc/iomem, like following.
==
[kamezawa@drpq linux-2.6.23-rc8-mm2]$ grep RAM /proc/iomem
00000000-0009ffff : System RAM
00100000-03ffffff : System RAM
04000000-04f1bfff : System RAM
04f1c000-6b4b9fff : System RAM
6b4ba000-6b797fff : System RAM
6b798000-6b799fff : System RAM
6b79a000-6b79dfff : System RAM
6b79e000-6b79efff : System RAM
6b79f000-6b7fbfff : System RAM
6b7fc000-6c629fff : System RAM
6c62a000-6c800fff : System RAM
6c801000-6c843fff : System RAM
6c844000-6c847fff : System RAM
6c848000-6c849fff : System RAM
6c84a000-6c85dfff : System RAM
6c85e000-6c85efff : System RAM
6c85f000-6cbfbfff : System RAM
6cbfc000-6d349fff : System RAM
6d34a000-6d3fbfff : System RAM
6d3fc000-6d455fff : System RAM
6d4fc000-6d773fff : System RAM
100000000-7ffffffff : System RAM
4080000000-40ffffffff : System RAM
14004000000-147ffffffff : System RAM
==

But there is a confusion.

i386 and x86_64 registers System RAM as IORESOUCE_MEM | IORESOUCE_BUSY.
ia64 registers System RAM as IORESOURCE_MEM.

Which is better ?

I ask this because current memory hotplug treat memory as IORESOUCE_MEM.
When memory hot-add occurs on x86_64, new memory is added as IORESOUCE_MEM.
memory hot-remove (now) can remove only IORESOUCE_MEM.

If ia64 should treat System RAM as IORESOUCE_MEM | IORESOUCE_BUSY, I'll write
a fix.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
