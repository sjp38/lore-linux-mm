Date: Wed, 3 Oct 2007 13:57:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-Id: <20071003135702.bdcf3f1b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071003015242.GC12049@parisc-linux.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
	<20071003015242.GC12049@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007 19:52:42 -0600
Matthew Wilcox <matthew@wil.cx> wrote:

> On Wed, Oct 03, 2007 at 10:31:36AM +0900, KAMEZAWA Hiroyuki wrote:
> > i386 and x86_64 registers System RAM as IORESOUCE_MEM | IORESOUCE_BUSY.
> > ia64 registers System RAM as IORESOURCE_MEM.
> > 
> > Which is better ?
> 
> Should probably be BUSY.  Non-BUSY regions can have io resources
> requested underneath them, but you wouldn't want a PCI device to be
> assigned an address which overlaps with physical memory.

Thank you.
It seems that I'll have to try modifing ia64 and memory hotplug in
the next -mm. 

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
