Date: Mon, 5 May 2003 10:47:25 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [CFT] re-slabify i386 pgd's and pmd's
Message-ID: <20030505174725.GN8978@holomorphy.com>
References: <20030505105213.GO8931@holomorphy.com> <20030505144042.B19403@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030505144042.B19403@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 05, 2003 at 03:52:13AM -0700, William Lee Irwin III wrote:
>> I would very much appreciate outside testers. Even though I've been
>> able to verify this boots and runs properly and survives several cycles
>> of restarting X on my non-PAE Thinkpad T21, that environment has never
>> been able to reproduce the bug. Those with the proper graphics hardware
>> to prod the affected codepaths into action are the ones best suited to
>> verify proper functionality.

On Mon, May 05, 2003 at 02:40:42PM +0200, Dave Jones wrote:
> For reference, Linus was seeing problems on i830 chipset with onboard
> graphics. Testers from all i8xx would be equally useful, as there are
> a lot of shared paths in agpgart for these chipsets.
> The onboard graphics part also seemed to be a factor. People using
> proper agp-slot graphics cards never saw this issue.

Okay, I have a success report of 4 stops and starts on an i845 chipset
being survived with this patch.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
