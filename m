Date: Wed, 05 Oct 2005 16:38:47 -0700 (PDT)
Message-Id: <20051005.163847.73221396.davem@davemloft.net>
Subject: Re: [PATCH 2/7] Fragmentation Avoidance V16: 002_usemap
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20051005144557.11796.2110.sendpatchset@skynet.csn.ul.ie>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	<20051005144557.11796.2110.sendpatchset@skynet.csn.ul.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Date: Wed,  5 Oct 2005 15:45:57 +0100 (IST)
Return-Path: <owner-linux-mm@kvack.org>
To: mel@csn.ul.ie
Cc: linux-mm@kvack.org, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, jschopp@austin.ibm.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> +	unsigned int type = 0;
 ...
> +	bitidx = pfn_to_bitidx(zone, pfn);
> +	usemap = pfn_to_usemap(zone, pfn);
> +

There seems no strong reason not to use "unsigned long" for "type" and
besides that will provide the required alignment for the bitops
interfaces.  "unsigned int" is not sufficient.

Then we also don't need to thing about "does this work on big-endian
64-bit" and things of that nature.

Please audit your other bitops uses for this issue.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
