Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8CB576B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 12:34:13 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 12:34:11 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B1F6D38C8080
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 12:33:54 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0UHXqjr313508
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 12:33:53 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0UHXi1S008743
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 15:33:47 -0200
Message-ID: <51095972.9050908@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 11:33:38 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zsmalloc: remove unused pool name
References: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com> <51093F43.2090503@linux.vnet.ibm.com> <20130130172159.GA24760@kroah.com>
In-Reply-To: <20130130172159.GA24760@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 01/30/2013 11:21 AM, Greg Kroah-Hartman wrote:
> On Wed, Jan 30, 2013 at 09:41:55AM -0600, Seth Jennings wrote:
>> On 01/30/2013 09:36 AM, Seth Jennings wrote:> zs_create_pool()
>> currently takes a name argument which is
>>> never used in any useful way.
>>>
>>> This patch removes it.
>>>
>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>
>> Crud, forgot the Acks...
>>
>> Acked-by: Nitin Gupta <ngupta@vflare.org>
>> Acked-by: Rik van Riel <riel@redhat.com>
> 
> {sigh} you just made me have to edit your patch by hand, you now owe me
> a beer...
> 

Now I owe you a beer and a keyboard.

https://plus.google.com/111049168280159033135/posts/YqyTxk3ujZ8

I'll try to get my act together.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
