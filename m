Date: Thu, 23 Sep 2004 21:01:17 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Patch/RFC]Removing zone and node ID from page->flags[0/3]
Message-ID: <20040924040117.GS9106@holomorphy.com>
References: <20040923135108.D8CC.YGOTO@us.fujitsu.com> <20040923232713.GJ9106@holomorphy.com> <20040923203516.0207.YGOTO@us.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040923203516.0207.YGOTO@us.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 23, 2004 at 08:51:58PM -0700, Yasunori Goto wrote:
> Thank you for comment.

At some point in the past, I wrote:
>> Looks relatively innocuous. I wonder if cosmetically we may want
>> s/struct zone_tbl/struct zone_table/

On Thu, Sep 23, 2004 at 08:51:58PM -0700, Yasunori Goto wrote:
> Do you mean "struct zone_table" is better as its name?
> If so, I'll change it.

I'm not extremely picky about naming conventions, and the abbreviation
isn't bad or anything. If there's someone else who also likes it better,
or if you yourself do, I'd change it then.


At some point in the past, I wrote:
>> I like the path compression in the 2-level radix tree.

On Thu, Sep 23, 2004 at 08:51:58PM -0700, Yasunori Goto wrote:
> Hmmmm.....
> Current radix tree code uses slab allocator.
> But, zone_table must be initialized before free_all_bootmem()
> and kmem_cache_alloc().
> So, if I use it for zone_table, I think I have to change radix tree
> code to use bootmem or have to write other original code.
> I'm not sure it is better way....

I meant it as an instance of a radix tree data structure, not to e.g.
be consolidated with the kernel's radix tree library functions (which
have the bootstrap ordering issues you describe preventing their use
for this kind of purpose). The generic software pagetables are also
radix trees, but similarly have constraints (e.g. use on machines with
hardware-interpreted pagetables) preventing consolidation with the
radix tree library code.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
