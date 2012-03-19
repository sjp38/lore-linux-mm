Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6CF986B00F1
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 14:55:28 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 19 Mar 2012 12:55:27 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0CB853E4004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:55:25 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2JIt1pd200338
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:55:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2JIswXl010261
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 12:55:00 -0600
Message-ID: <4F678100.1000707@linux.vnet.ibm.com>
Date: Mon, 19 Mar 2012 13:54:56 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: add user-definable alloc/free funcs
References: <1331931888-14175-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120316213227.GB24556@kroah.com>
In-Reply-To: <20120316213227.GB24556@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/16/2012 04:32 PM, Greg Kroah-Hartman wrote:
> On Fri, Mar 16, 2012 at 04:04:48PM -0500, Seth Jennings wrote:
>> This patch allows a zsmalloc user to define the page
>> allocation and free functions to be used when growing
>> or releasing parts of the memory pool.
>>
>> The functions are passed in the struct zs_pool_ops parameter
>> of zs_create_pool() at pool creation time.  If this parameter
>> is NULL, zsmalloc uses alloc_page and __free_page() by default.
>>
>> While there is no current user of this functionality, zcache
>> development plans to make use of it in the near future.
> 
> I'm starting to get tired of seeing new features be added to this chunk
> of code, and the other related bits, without any noticable movement
> toward getting it merged into the mainline tree.

Fair enough

> 
> So, I'm going to take a stance here and say, no more new features until
> it gets merged into the "real" part of the kernel tree, as you all
> should not be spinning your wheels on new stuff, when there's no
> guarantee that the whole thing could just be rejected outright tomorrow.
> 
> I'm sorry, I know this isn't fair for your specific patch, but we have
> to stop this sometime, and as this patch adds code isn't even used by
> anyone, its a good of a time as any.

So, this the my first "promotion from staging" rodeo.  I would love to
see this code mainlined ASAP.  How would I/we go about doing that?

I guess another way to ask is, what needs to be done in the way of
code quality and acks in the community to promote zcache to
/drivers/misc for example?

Also, the tmem part of zcache will (probably, Dan?) be broken
out an placed in /lib.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
