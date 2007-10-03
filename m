Date: Wed, 3 Oct 2007 10:43:13 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-ID: <20071003164313.GH12049@parisc-linux.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com> <1191429433.4939.49.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1191429433.4939.49.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 03, 2007 at 09:37:13AM -0700, Dave Hansen wrote:
> I think we should take system ram out of the iomem file, at least.

Rubbish.  iomem is a representation of the physical addresses in the
system as seen from the CPU's perspective.  As I said in my previous
mail in this thread, if you attempt to map a device's BAR over the top
of physical RAM, things will go poorly for you.

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
