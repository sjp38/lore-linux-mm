Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D8A5F6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:48:57 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 14:48:57 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 76D6CC40004
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 20:48:52 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BKmXZO279048
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 14:48:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BKmWNa022582
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 14:48:32 -0600
Message-ID: <4FFDE69C.8080205@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 15:48:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120704204325.GB2924@localhost.localdomain> <4FF6FF1F.5090701@linux.vnet.ibm.com>	<4FFAE37F.70403@linux.vnet.ibm.com> <CAPbh3rtXVf_GPKZ2dA2nWaj=h6aYztntQ-oFD5Pg0j65BbOvmA@mail.gmail.com>
In-Reply-To: <CAPbh3rtXVf_GPKZ2dA2nWaj=h6aYztntQ-oFD5Pg0j65BbOvmA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad@darnok.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 02:42 PM, Konrad Rzeszutek Wilk wrote:
>>>> Which architecture was this under? It sounds x86-ish? Is this on
>>>> Westmere and more modern machines? What about Core2 architecture?
>>>>
>>>> Oh how did it work on AMD Phenom boxes?
>>>
>>> I don't have a Phenom box but I have an Athlon X2 I can try out.
>>> I'll get this information next Monday.
>>
>> Actually, I'm running some production stuff on that box, so
>> I rather not put testing stuff on it.  Is there any
>> particular reason that you wanted this information? Do you
>> have a reason to believe that mapping will be faster than
>> copy for AMD procs?
> 
> Sorry for the late response. Working on some ugly bug that is taking
> more time than anticipated.
> My thoughts were that these findings are based on the hardware memory
> prefetcher. The Intel
> machines - especially starting with Nehelem have some pretty
> impressive prefetcher where
> even doing in a linked list 'prefetch' on the next node is not beneficial.
> 
> Perhaps the way to leverage this is to use different modes depending
> on the bulk of data?
> When there is a huge amount use the old method, but for small use copy
> (as it would
> in theory stay in the cache longer).

Not sure what you mean by "bulk" or "huge amount" but the
maximum size of mapped object is PAGE_SIZE and the typical
size more around PAGE_SIZE/2. So that is what I'm
considering.  Do you think it makes a difference with copies
that small?

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
