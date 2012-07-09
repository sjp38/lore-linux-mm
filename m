Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 179026B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 01:56:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 9 Jul 2012 11:25:57 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q695trAY60752118
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 11:25:54 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q69BPRDr015959
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 16:55:27 +0530
Message-ID: <4FFA7266.6090408@linux.vnet.ibm.com>
Date: Mon, 09 Jul 2012 13:55:50 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/9] zcache: fix refcount leak
References: <4FE97792.9020807@linux.vnet.ibm.com> <4FE977AA.2090003@linux.vnet.ibm.com> <20120626223651.GB6561@localhost.localdomain> <4FEA905A.4070207@linux.vnet.ibm.com> <20120627054456.GA18869@kroah.com>
In-Reply-To: <20120627054456.GA18869@kroah.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

On 06/27/2012 01:44 PM, Greg Kroah-Hartman wrote:
> On Wed, Jun 27, 2012 at 12:47:22PM +0800, Xiao Guangrong wrote:
>> On 06/27/2012 06:36 AM, Konrad Rzeszutek Wilk wrote:
>>> On Tue, Jun 26, 2012 at 04:49:46PM +0800, Xiao Guangrong wrote:
>>>> In zcache_get_pool_by_id, the refcount of zcache_host is not increased, but
>>>> it is always decreased in zcache_put_pool
>>>
>>> All of the patches (1-9) look good to me, so please also
>>> affix 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>'.
>>>
>>
>> Thank you, Konrad!
>>
>> Greg, need i repost this patchset with Konrad's Reviewed-by?
> 
> No, I can add it when I apply them.
> 


Greg, sorry to trouble you but this patches stayed in the list for
nearly two weeks. If it is ok, could you please apply them? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
