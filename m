Date: Fri, 03 Jun 2005 11:43:31 -0700 (PDT)
Message-Id: <20050603.114331.85417605.davem@davemloft.net>
Subject: Re: Avoiding external fragmentation with a placement policy
 Version 12
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1117816980.5985.17.camel@localhost>
References: <429FFC21.1020108@yahoo.com.au>
	<369850000.1117807062@[10.10.2.4]>
	<1117816980.5985.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 03 Jun 2005 09:43:00 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com
Cc: mbligh@mbligh.org, nickpiggin@yahoo.com.au, jschopp@austin.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> Are those loopback allocations GFP_KERNEL?

It depends :-)  Most of the time, the packets will be
allocated at sendmsg() time for the user, and thus GFP_KERNEL.

But the flags may be different if, for example, the packet
is being allocated for the NFS client/server code, or some
asynchronous packet generated at software interrupt time
(TCP ACKs, ICMP replies, etc.).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
