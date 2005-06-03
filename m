Date: Thu, 02 Jun 2005 22:51:10 -0700 (PDT)
Message-Id: <20050602.225110.03979632.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <358040000.1117777372@[10.10.2.4]>
References: <357240000.1117776882@[10.10.2.4]>
	<20050602.223712.41634750.davem@davemloft.net>
	<358040000.1117777372@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Martin J. Bligh" <mbligh@mbligh.org>
Date: Thu, 02 Jun 2005 22:42:52 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: mbligh@mbligh.org
Cc: nickpiggin@yahoo.com.au, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> but it's vastly different order of magnitude than touching disk.
> Can we not do a "sniff alloc" first (ie if this is easy, give it
> to me, else just fail and return w/o reclaim), then fall back to
> smaller allocs?

That's what AF_UNIX does.

But with other protocols, we can't jiggle the loopback
MTU just because higher allocs no longer are easily
obtainable.

Really, the networking should not try to grab anything
more than SKB_MAX_ORDER unless the device's MTU is
larger than PAGE_SIZE << SKB_MAX_ORDER, which loopback's
"16K - fudge" is not.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
