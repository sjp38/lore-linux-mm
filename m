Subject: Re: [PATCH] per-zone kswapd process
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <20020913045938.GG2179@holomorphy.com>
References: <3D815C8C.4050000@us.ibm.com> <3D81643C.4C4E862C@digeo.com>
	<20020913045938.GG2179@holomorphy.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 13 Sep 2002 14:05:52 +0100
Message-Id: <1031922352.9056.14.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-09-13 at 05:59, William Lee Irwin III wrote:
> Machines without observable NUMA effects can benefit from it if it's
> per-zone. It also follows that if there's more than one task doing this,
> page replacement is less likely to block entirely. Last, but not least,
> when I devised it, "per-zone" was the theme.

It will also increase the amount of disk head thrashing surely ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
