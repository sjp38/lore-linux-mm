Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DBF3F6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 00:30:47 -0400 (EDT)
Message-ID: <5153C76E.3050203@oracle.com>
Date: Thu, 28 Mar 2013 12:30:38 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: zsmalloc zbud hybrid design discussion?
References: <ef105888-1996-4c78-829a-36b84973ce65@default>
In-Reply-To: <ef105888-1996-4c78-829a-36b84973ce65@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 03/28/2013 04:04 AM, Dan Magenheimer wrote:
> Seth and all zproject folks --
> 
> I've been giving some deep thought as to how a zpage
> allocator might be designed that would incorporate the
> best of both zsmalloc and zbud.
> 
> Rather than dive into coding, it occurs to me that the
> best chance of success would be if all interested parties
> could first discuss (on-list) and converge on a design
> that we can all agree on.  If we achieve that, I don't
> care who writes the code and/or gets the credit or
> chooses the name.  If we can't achieve consensus, at
> least it will be much clearer where our differences lie.
> 
> Any thoughts?

Can't agree more!
Hoping we would agree on a design dealing well with
density/fragmentation/pageframe-reclaim and better integration with MM.
And then working together to implement it.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
