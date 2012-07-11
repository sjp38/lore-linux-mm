Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id CE2856B0062
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 15:42:08 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so4678250wib.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 12:42:07 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <4FFAE37F.70403@linux.vnet.ibm.com>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<20120704204325.GB2924@localhost.localdomain>
	<4FF6FF1F.5090701@linux.vnet.ibm.com>
	<4FFAE37F.70403@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 15:42:06 -0400
Message-ID: <CAPbh3rtXVf_GPKZ2dA2nWaj=h6aYztntQ-oFD5Pg0j65BbOvmA@mail.gmail.com>
Subject: Re: [PATCH 0/4] zsmalloc improvements
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

>>> Which architecture was this under? It sounds x86-ish? Is this on
>>> Westmere and more modern machines? What about Core2 architecture?
>>>
>>> Oh how did it work on AMD Phenom boxes?
>>
>> I don't have a Phenom box but I have an Athlon X2 I can try out.
>> I'll get this information next Monday.
>
> Actually, I'm running some production stuff on that box, so
> I rather not put testing stuff on it.  Is there any
> particular reason that you wanted this information? Do you
> have a reason to believe that mapping will be faster than
> copy for AMD procs?

Sorry for the late response. Working on some ugly bug that is taking
more time than anticipated.
My thoughts were that these findings are based on the hardware memory
prefetcher. The Intel
machines - especially starting with Nehelem have some pretty
impressive prefetcher where
even doing in a linked list 'prefetch' on the next node is not beneficial.

Perhaps the way to leverage this is to use different modes depending
on the bulk of data?
When there is a huge amount use the old method, but for small use copy
(as it would
in theory stay in the cache longer).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
