Subject: Re: [PATCH 01/05] NUMA: Generic code
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
	<200511110516.37980.ak@suse.de>
	<aec7e5c30511150034t5ff9e362jb3261e2e23479b31@mail.gmail.com>
	<200511151515.05201.ak@suse.de>
	<aec7e5c30511152122w70703fbfl98bd377fb6fb9af4@mail.gmail.com>
From: Andi Kleen <ak@suse.de>
Date: 16 Nov 2005 08:48:39 +0100
In-Reply-To: <aec7e5c30511152122w70703fbfl98bd377fb6fb9af4@mail.gmail.com>
Message-ID: <p73sltxowx4.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pj@sgi.com, werner@almesberger.net
List-ID: <linux-mm.kvack.org>

Magnus Damm <magnus.damm@gmail.com> writes:
> 
> For testing, your NUMA emulation code is perfect IMO. But for memory
> resource control your NUMA emulation code may be too simple.
> 
> With my patch, CONFIG_NUMA_EMU provides a way to partition a machine
> into several smaller nodes, regardless if the machine is using NUMA or
> not.
> 
> This NUMA emulation code together with CPUSETS could be seen as a
> simple alternative to the memory resource control provided by CKRM.

I believe Werner tried to use it at some point for that and it just
didn't work very well. So it doesn't seem to be very useful for
that usecase.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
