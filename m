Date: Fri, 2 Apr 2004 19:59:28 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402195927.A6659@infradead.org>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040402104334.A871@infradead.org> <20040402164634.GF21341@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040402164634.GF21341@dualathlon.random>; from andrea@suse.de on Fri, Apr 02, 2004 at 06:46:34PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 06:46:34PM +0200, Andrea Arcangeli wrote:
> it's not clear why this triggered, bad_page only shows the "master"
> compound page and not the contents of the slave page that triggered the
> bad_page. Can you try again with this incremental patch applied?

Bad page state at destroy_compound_page (in process 'swapper', page c0772380)
flags:0x00080008 mapping:00000000 mapped:0 count:134217728 private:0xc07721ff
Backtrace:
Call trace:
 [c000b5c8] dump_stack+0x18/0x28
 [c0048b64] bad_page+0x74/0xbc
 [c0048c7c] destroy_compound_page+0x80/0xb8
 [c0048ed0] free_pages_bulk+0x21c/0x220
 [c0049030] __free_pages_ok+0x15c/0x188
 [c004d520] slab_destroy+0x140/0x234
 [c00505f0] reap_timer_fnc+0x1e4/0x2b8
 [c002feac] run_timer_softirq+0x134/0x1fc
 [c002abd0] do_softirq+0x140/0x144
 [c0009e5c] timer_interrupt+0x2d0/0x300
 [c0007cac] ret_from_except+0x0/0x14
 [c000381c] ppc6xx_idle+0xe4/0xf0
 [c0009b7c] cpu_idle+0x28/0x38
 [c00038c4] rest_init+0x50/0x60
 [c0364784] start_kernel+0x198/0x1d8
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
