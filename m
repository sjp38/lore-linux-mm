Date: Tue, 13 Mar 2007 14:07:22 -0700 (PDT)
Message-Id: <20070313.140722.72711732.davem@davemloft.net>
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070313202125.GO10394@waste.org>
References: <20070313200313.GG10459@waste.org>
	<45F706BC.7060407@goop.org>
	<20070313202125.GO10394@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Matt Mackall <mpm@selenic.com>
Date: Tue, 13 Mar 2007 15:21:25 -0500
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: jeremy@goop.org, nickpiggin@yahoo.com.au, akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Because the fan-out is large, the bulk of the work is bringing the last
> layer of the tree into cache to find all the pages in the address
> space. And there's really no way around that.

That's right.

And I will note that historically we used to be much worse
in this area, as we used to walk the page table tree twice
on address space teardown (once to hit the PTE entries, once
to free the page tables).

Happily it is a one-pass algorithm now.

But, within active VMA ranges, we do have to walk all
the bits at least one time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
