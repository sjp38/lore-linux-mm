Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 210126B0005
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:07:34 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 28 Jan 2013 12:07:32 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C639238C8047
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:07:29 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0SH7TF7260896
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:07:29 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0SH7Mv3015572
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 12:07:25 -0500
Message-ID: <5106B03E.6070302@linux.vnet.ibm.com>
Date: Mon, 28 Jan 2013 11:07:10 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] staging: zsmalloc: various cleanups/improvments
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com> <20130128034740.GE3321@blaptop>
In-Reply-To: <20130128034740.GE3321@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/27/2013 09:47 PM, Minchan Kim wrote:
> Hi Seth,
> 
> On Fri, Jan 25, 2013 at 11:46:14AM -0600, Seth Jennings wrote:
>> These patches are the first 4 patches of the zswap patchset I
>> sent out previously.  Some recent commits to zsmalloc and
>> zcache in staging-next forced a rebase. While I was at it, Nitin
>> (zsmalloc maintainer) requested I break these 4 patches out from
>> the zswap patchset, since they stand on their own.
> 
> [2/4] and [4/4] is okay to merge current zsmalloc in staging but
> [1/4] and [3/4] is dependent on zswap so it should be part of
> zswap patchset.

Just to clarify, patches 1 and 3 are _not_ dependent on zswap.  They
just introduce changes that are only needed by zswap.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
