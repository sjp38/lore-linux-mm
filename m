Date: Wed, 15 Jan 2003 07:24:40 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 48GB NUMA-Q boots, with major IO-APIC hassles
Message-ID: <840980000.1042644279@titus>
In-Reply-To: <20030115105802.GQ940@holomorphy.com>
References: <20030115105802.GQ940@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> (2) MAX_IO_APIC's got clobbered in the subarch cleanups.
> 	-- CONFIG_X86_NUMA was removed, use CONFIG_X86_NUMAQ
> 	-- this is greppable, folks...

That wasn't the subarch cleanups that removed it, please be careful
what you're saying. I plead not guilty to that one.

> (4) PCI bridges get misnumbered children.
> 	-- Brew up a PCI hook for giving child buses their bus numbers.
> 	-- Basically, fwd port mbligh's fix for 2.4.x more cleanly.
> 	-- Okay, not IO-APIC-related, but it annoys me greatly.
> 	-- ink is at least trying to steer me in the right direction here.

Additional PCI-PCI bridges (eg starfire cards) have never been supported 
in non-boot quads. It's not impossible, but don't be suprised if it 
doesn't work.

> (5) Booting with notsc panic()'s.
> 	-- Remove tsc_disable assignment in the __setup() call.
> 	-- I'd be much obliged if the SMP TSC issues were at long
> 	-- last conclusively dealt with. Not IO-APIC-related either,
> 	-- but also very annoying.

You don't have PIT support compiled in, and you turned off TSC support,
leaving yourself with no timer. There's a patch in my tree to force on
PIT support for NUMA-Q.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
