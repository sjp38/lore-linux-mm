Date: Mon, 19 Aug 2002 14:22:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.31 i386 mem_map usage corrections
Message-ID: <20020819212235.GC21683@holomorphy.com>
References: <20020819102156.GJ18350@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020819102156.GJ18350@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@zip.com.au, gone@us.ibm.com, Martin.Bligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2002 at 03:21:56AM -0700, William Lee Irwin III wrote:
> With these fixes (modulo merging), most notably the fix for
> pmd_populate(), I was able to boot and run userspace on a 16x/16G NUMA-Q
> in combination with Pat Gaughen's x86 discontigmem patches.

In case this wasn't clear, this is a fix for what is (AFAIK)
the only reliably reproducible scenario reproducing the BUG on
page->pte.chain != NULL.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
