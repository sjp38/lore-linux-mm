From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH -mm -v4 1/3] i386/x86_64 boot: setup data
Date: Tue, 9 Oct 2007 16:04:49 +0200
References: <1191912010.9719.18.camel@caritas-dev.intel.com> <200710091313.45003.ak@suse.de> <851fc09e0710090700u21b2db91yca2d5e88cb7a502a@mail.gmail.com>
In-Reply-To: <851fc09e0710090700u21b2db91yca2d5e88cb7a502a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710091604.50263.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, "Eric W. Biederman" <ebiederm@xmission.com>, akpm@linux-foundation.org, Yinghai Lu <yhlu.kernel@gmail.com>, Chandramouli Narayanan <mouli@linux.intel.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 09 October 2007 16:00:57 huang ying wrote:
> On 10/9/07, Andi Kleen <ak@suse.de> wrote:
> >
> > > Care to add a line of documentation if you keep it in mm/memory.c?
> >
> > It would be better to just use early_ioremap() (or ioremap())
> >
> > That is how ACPI who has similar issues accessing its tables solves this.
> 
> Yes. That is another solution. But there is some problem about
> early_ioremap (boot_ioremap, bt_ioremap for i386) or ioremap.
> 
> - ioremap can not be used before mem_init.
> - For i386, boot_ioremap can map at most 4 pages, bt_ioremap can map
> at most 16 pages. This will be an unnecessary constrains for size of
> setup_data.

That could be easily extended if needed. But I don't see why we would
need that much setup data anyways. Limiting it to let's say 16KB
seems entirely reasonable. And if some kernel ever needs more it can 
be still extended.

The biggest item is probably the command line and i don't see why
that should be more than a one or two KB.

> - For i386, the virtual memory space of ioremap is limited too.

That will be all freed and again the data shouldn't be that big.

-Andi

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
