Date: Wed, 2 Jul 2003 15:14:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030702221411.GG26348@holomorphy.com>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <Pine.LNX.4.53.0307021641560.11264@skynet> <20030702171159.GG23578@dualathlon.random> <461030000.1057165809@flay> <20030702174700.GJ23578@dualathlon.random> <20030702214032.GH20413@holomorphy.com> <563510000.1057182494@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563510000.1057182494@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> (c) redo the logic around page_convert_anon() and incrementally build
>> 	pte_chains for remap_file_pages().
>> 	The anobjrmap code did exactly this, but it was chaining
>> 	distinct user virtual addresses instead.
>> After all 3 are done, remap_file_pages() integrates smoothly into the VM,
>> requires no magical privileges, nothing magical or brutally invasive
>> that would scare people just before 2.6.0 is required, and the big
>> apps can get their magical lowmem savings by just mlock()'ing _anything_
>> they do massive sharing with, regardless of remap_file_pages().

On Wed, Jul 02, 2003 at 02:48:14PM -0700, Martin J. Bligh wrote:
> If you have (anon) object based rmap, I don't see why you want to build
> a pte_chain on a per-page basis - keeping this info on a per linear
> area seems much more efficient. We still have a reverse mapping for
> everything this way.

Eh? This is just suggesting using similar devices as were used in the
anobjrmap patch. I'm not terribly convinced about the remap_file_pages()
extents, since they're only going to be a factor of 8 or so space
reduction.

anobjrmap actually didn't use vma-like devices for anon pages, it merely
chained mm's that could share anon pages (fork()'s between exec()'s)
in a list that could be scanned, tagged anon pages with vaddrs, and
then walks that list of mm's when unmapping or checking referenced bits.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
