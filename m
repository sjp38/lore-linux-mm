Date: Thu, 27 Mar 2003 21:08:39 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 48GB NUMA-Q boots, with major IO-APIC hassles
Message-ID: <20030328050839.GP1350@holomorphy.com>
References: <20030115105802.GQ940@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030115105802.GQ940@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 15, 2003 at 02:58:02AM -0800, William Lee Irwin III wrote:
> Minor extrapolation: aside from potential explosions in very unusual
> corner cases, with these hacks/workarounds 64GB NUMA-Q should boot and
> run (slowly) with an approximate LowTotal of 173296 kB. The main obstacle
> is our setup here would require an additional NR_CPUS > BITS_PER_LONG
> patch, and there isn't much local interest in even seeing whether or how
> poorly it would run without working patches (e.g. hugh's MMUPAGE_SIZE that
> I'm fwd. porting) to do something about runaway mem_map lowmem consumption.

I was only 3MB off wrt. mainline's 64GB LowTotal, not bad at all:

HighTotal:    65134592 kB
HighFree:     65116864 kB
LowTotal:       176076 kB
LowFree:        144180 kB

Turns out NR_CPUS > BITS_PER_LONG was avoided. I'll dig up whatever else
I can here. AIM7 with 10000 tasks and various other things were runnable
on 48GB, but I still need to straighten various fragmentation things out
before benching produces meaningful numbers instead of runs vs. doesn't.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
