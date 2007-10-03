Date: Tue, 2 Oct 2007 19:52:42 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-ID: <20071003015242.GC12049@parisc-linux.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 03, 2007 at 10:31:36AM +0900, KAMEZAWA Hiroyuki wrote:
> i386 and x86_64 registers System RAM as IORESOUCE_MEM | IORESOUCE_BUSY.
> ia64 registers System RAM as IORESOURCE_MEM.
> 
> Which is better ?

Should probably be BUSY.  Non-BUSY regions can have io resources
requested underneath them, but you wouldn't want a PCI device to be
assigned an address which overlaps with physical memory.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
