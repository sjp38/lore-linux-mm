Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 69BA46B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:10:20 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 14:10:19 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 9573F38C8029
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:10:10 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3BKAA6q294102
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:10:10 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3BKAA0N020634
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 17:10:10 -0300
Date: Thu, 11 Apr 2013 15:10:02 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: zsmalloc zbud hybrid design discussion?
Message-ID: <20130411201002.GD28296@cerebellum>
References: <ef105888-1996-4c78-829a-36b84973ce65@default>
 <20130411193534.GB28296@cerebellum>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411193534.GB28296@cerebellum>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 11, 2013 at 02:35:34PM -0500, Seth Jennings wrote:
> Not a requirement:
> 
> Compaction - compaction would basically involve creating a virtual address
> space of sorts, which zsmalloc is capable of through its API with handles,
> not pointer.  However, as Dan points out this requires a structure the maintain
> the mappings and adds to complexity.  Additionally, the need for compaction
> diminishes as the allocations are short-lived with frontswap backends doing
> writeback and cleancache backends shrinking.

Of course I say this, but for zram, this can be important as the allocations
can't be moved out of memory and, therefore, are long lived.  I was speaking
from the zswap perspective.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
