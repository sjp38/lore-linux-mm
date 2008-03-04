Date: Mon, 3 Mar 2008 17:30:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] x86_64: Cleanup non-smp usage of cpu maps v3
Message-Id: <20080303173011.b0d9a89d.akpm@linux-foundation.org>
In-Reply-To: <20080303170235.4334e841.akpm@linux-foundation.org>
References: <20080219203335.866324000@polaris-admin.engr.sgi.com>
	<20080219203336.177905000@polaris-admin.engr.sgi.com>
	<20080303170235.4334e841.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com, mingo@elte.hu, tglx@linutronix.de, ak@suse.de, clameter@sgi.com, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Mar 2008 17:02:35 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> I was unable to bisect it more finely than this:
> 
> init-move-setup-of-nr_cpu_ids-to-as-early-as-possible-v3.patch
> generic-percpu-infrastructure-to-rebase-the-per-cpu-area-to-zero-v3.patch OK
> x86_64-fold-pda-into-per-cpu-area-v3.patch
> x86_64-fold-pda-into-per-cpu-area-v3-fix.patch				
> x86_64-cleanup-non-smp-usage-of-cpu-maps-v3.patch			BAD
> 
> because when x86_64-cleanup-non-smp-usage-of-cpu-maps-v3.patch was removed
> the machine hung quite early, when playing around with TSC calibration I
> think.

This just happened again with the patches dropped, so it is a separate bug -
just another regression.


I now recall that it has been happening on every fifth-odd boot for a few
weeks now.  The machine prints

Time: tsc clocksource has been installed

then five instances of "system 00:01: iomem range 0x...", then it hangs. 
ie: it never prints "system 00:01: iomem range 0xfe600000-0xfe6fffff has
been reserved" from http://userweb.kernel.org/~akpm/dmesg-akpm2.txt.

It may have some correlation with whether the machine was booted via
poweron versus `reboot -f', dunno.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
