Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 0/7] Sparsemem Virtual Memmap V5
Date: Fri, 13 Jul 2007 15:02:17 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01EA6524@scsmsx411.amr.corp.intel.com>
In-Reply-To: <20070713104044.0d090c79.akpm@linux-foundation.org>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> It would be nice to see a bit of spirited reviewing from the affected arch
> maintainers and mm people...

I'm 100% in favour of the direction this patch is taking ... eventually
it will allow getting rid of several config options, and thus 2^several
less config options to test.

On the question of whether it should be squeezed into 2.6.23 ... I have
mixed feelings.  On the negative side:

1) There is a small performance regression for ia64 (which is promised
to go away when bigger pages are used for the mem_map, but I'd like to
see that this really does fix the issue).

2) Fujitsu pointed out that there is work to be done to port HOTPLUG
code to this.

On the positive side:
1) There are few ia64 developers working on -mm ... so progress will
continue to be glacial unless this goes into mainline.

2) The patch appears to co-exist with all the existing CONFIG options,
so it doesn't break anything (well, all my test configs still compile
cleanly ... I haven't actually test booted them all yet).

Finally one gripe with the current version of the patch.  This debug
trace is WAY too verbose during boot!

mm/sparse.c
+			printk(KERN_DEBUG "[%lx-%lx] PTE ->%p on node %d\n",
+				addr, addr + PAGE_SIZE - 1, p, node);

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
