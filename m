Date: Fri, 23 Jan 2004 16:04:35 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Can a page be HighMem without having the HighMem flag set?
Message-ID: <20040124000435.GC1016@holomorphy.com>
References: <1074824487.12774.185.camel@laptop-linux> <20040123022617.GY1016@holomorphy.com> <1074828647.12774.212.camel@laptop-linux> <1074900629.2024.44.camel@laptop-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1074900629.2024.44.camel@laptop-linux>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@users.sourceforge.net>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 24, 2004 at 12:30:29PM +1300, Nigel Cunningham wrote:
> <4> BIOS-e820: 0000000000000000 - 000000000009e000 (usable)
> <4> BIOS-e820: 000000000009e000 - 00000000000a0000 (reserved)
> <4> BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
> <4> BIOS-e820: 0000000000100000 - 00000000efff6500 (usable)
> <4> BIOS-e820: 00000000efff6500 - 00000000f0000000 (ACPI data)
> <4> BIOS-e820: 00000000fffb0000 - 0000000100000000 (reserved)
> <4> BIOS-e820: 0000000100000000 - 0000000400000000 (usable)
> It's the pages efff6000- which are causing me grief. if I understand
> things correctly, page_is_ram is returning 0 for those pages, and as a
> result they get marked reserved and not HighMem by one_highpage_init.
> I suppose, then, that I need to check for and ignore pages >
> highstart_pfn where PageHighMem is not set/Reserved is set. (Either
> okay?).

If it's reserved, most/all bets are off -- only the "owner" of the thing
understands what it is. Some more formally-defined semantics for reserved
are needed, but 2.6 is unlikely to get them soon.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
