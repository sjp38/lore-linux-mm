Date: Fri, 4 Jul 2003 13:17:15 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704201715.GH955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com> <13170000.1057335490@[10.10.2.4]> <20030704183106.GC955@holomorphy.com> <14820000.1057346400@[10.10.2.4]> <20030704193135.GF955@holomorphy.com> <16900000.1057348432@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16900000.1057348432@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Zwane Mwaikambo <zwane@arm.linux.org.uk>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote (on Friday, July 04, 2003 12:31:35 -0700):
>> Dirtier, but possibly lower line count.

On Fri, Jul 04, 2003 at 12:53:54PM -0700, Martin J. Bligh wrote:
> I disagree with the "dirtier" bit, but still. I'd rather have this sort
> of stuff put into subarch, where most people don't have to look at it.
> More to the point, the changes would be confined to the big-iron arches,
> and have less chance of breaking anyone else for things they don't
> care about, nor do them any benefit. Touching this code is fragile as
> hell, so if it can be confined, it should be ...
> It'd also remove the long-standing abuse of phys_cpu_present_map, which
> would probably make the rest of the code clearer.

That's a change with deeper semantic implications as it's relying on
different information.

The phys_cpu_present_map bits were to divorce its width from NR_CPUS
in a portable way. Shifting to bios_cpu_map[] should only change cpu
wakeup. IO-APIC physid reassignment code still needs a variable-width
map (I suppose you could use integers) of some kind.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
