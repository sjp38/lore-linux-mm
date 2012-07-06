Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 1C6A16B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:10:34 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 6 Jul 2012 09:10:31 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 22BB83E40049
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 15:09:10 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q66F8oir101204
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 09:08:53 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q66F8fD0024488
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 09:08:41 -0600
Message-ID: <4FF6FF1F.5090701@linux.vnet.ibm.com>
Date: Fri, 06 Jul 2012 10:07:11 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120704204325.GB2924@localhost.localdomain>
In-Reply-To: <20120704204325.GB2924@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/04/2012 03:43 PM, Konrad Rzeszutek Wilk wrote:
> On Mon, Jul 02, 2012 at 04:15:48PM -0500, Seth Jennings wrote:
>> This exposed an interesting and unexpected result: in all
>> cases that I tried, copying the objects that span pages instead
>> of using the page table to map them, was _always_ faster.  I could
>> not find a case in which the page table mapping method was faster.
> 
> Which architecture was this under? It sounds x86-ish? Is this on
> Westmere and more modern machines? What about Core2 architecture?
> 
> Oh how did it work on AMD Phenom boxes?

I don't have a Phenom box but I have an Athlon X2 I can try out.
I'll get this information next Monday.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
