Date: Thu, 23 Sep 2004 16:27:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Patch/RFC]Removing zone and node ID from page->flags[0/3]
Message-ID: <20040923232713.GJ9106@holomorphy.com>
References: <20040923135108.D8CC.YGOTO@us.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040923135108.D8CC.YGOTO@us.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 23, 2004 at 03:55:16PM -0700, Yasunori Goto wrote:
> I updated my patches which remove zone and node ID from page->flags.
> Page->flags is 32bit space and 19 bits of them have already been used on
> 2.6.9-rc2-mm2 kernel, and zone and node ID uses 8 bits on 32 archtecture.
> So, remaining bits is only 5 bits. In addition, only 3 bits have remained
> on 2.6.8.1 stock kernel.
> But, my patches make more 8 bits space in page->flags again.
> And kernel can use large number of node and types of zone.
> These patches are for 2.6.9-rc2-mm2. 

Looks relatively innocuous. I wonder if cosmetically we may want
s/struct zone_tbl/struct zone_table/

I like the path compression in the 2-level radix tree.

Thanks.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
