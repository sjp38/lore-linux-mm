Date: Fri, 13 Sep 2002 14:30:42 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] per-zone kswapd process
Message-ID: <20020913213042.GD3530@holomorphy.com>
References: <3D815C8C.4050000@us.ibm.com> <3D81643C.4C4E862C@digeo.com> <20020913045938.GG2179@holomorphy.com> <1031922352.9056.14.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <1031922352.9056.14.camel@irongate.swansea.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-09-13 at 05:59, William Lee Irwin III wrote:
>> Machines without observable NUMA effects can benefit from it if it's
>> per-zone. It also follows that if there's more than one task doing this,
>> page replacement is less likely to block entirely. Last, but not least,
>> when I devised it, "per-zone" was the theme.

On Fri, Sep 13, 2002 at 02:05:52PM +0100, Alan Cox wrote:
> It will also increase the amount of disk head thrashing surely ?

I doubt it. Writeout isn't really supposed to happen there in 2.4
either, except under duress. OTOH I've not been doing much with this
directly since rmap10c.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
