Date: Wed, 20 Aug 2003 00:47:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test3-mm3
Message-ID: <20030820074749.GG4306@holomorphy.com>
References: <20030819013834.1fa487dc.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030819013834.1fa487dc.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2003 at 01:38:34AM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm3/
> . More CPU scheduler changes
> . The regression with reaim which was due to the CPU scheduler changes
>   seems to have largely gone away, but it was never a large effect in my
>   testing.  Needs retesting please.
> . A series of Cardbus driver updates.

Looks good. There are some ACPI bits to clean up after, but with the
preliminary ACPI workarounds and the cyclone timer one-liner, 16x/64GB
x440's come up and run userspace just fine with XKVA enabled (haven't
bothered with NUMA-Q since the setup there is inconvenient for others).
I think it was all wrapped up by the combination of the pmd and TSS
fixes (at least to get these boxen going).


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
