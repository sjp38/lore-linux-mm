Date: Thu, 27 Mar 2008 20:44:31 -0700 (PDT)
Message-Id: <20080327.204431.201380891.davem@davemloft.net>
Subject: Re: [patch 1/2]: x86: implement pte_special
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080328033149.GD8083@wotan.suse.de>
References: <20080328025541.GB8083@wotan.suse.de>
	<20080327.202334.250213398.davem@davemloft.net>
	<20080328033149.GD8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 28 Mar 2008 04:31:50 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> Basically, the pfn-based mapping insertion (vm_insert_pfn, remap_pfn_range)
> calls pte_mkspecial. And that tells fast_gup "hands off".

I don't think it's wise to allocate a "soft PTE bit" for this on every
platform, especially for such a limited use case.

Is it feasible to test the page instead?  Or are we talking about
cases where there may not be a backing page?

If the issue is to discern things like I/O mappings and such vs. real
pages, there are ways a platform can handle that without a special
bit.

That would leave us with real memory that does not have backing
page structs, and we have a way to test that too.

The special PTE bit seems superfluous to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
