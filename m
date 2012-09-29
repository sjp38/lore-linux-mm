Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2A22E6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 22:54:33 -0400 (EDT)
Message-ID: <506662DD.4030309@oracle.com>
Date: Sat, 29 Sep 2012 10:54:21 +0800
From: Zhenzhong Duan <zhenzhong.duan@oracle.com>
Reply-To: zhenzhong.duan@oracle.com
MIME-Version: 1.0
Subject: Re: [PATCH -v2] mm: frontswap: fix a wrong if condition in frontswap_shrink
References: <505C27FE.5080205@oracle.com>  <1348745730.1512.19.camel@x61.thuisdomein> <50651CF5.5030903@oracle.com> <1348844071.1553.14.camel@x61.thuisdomein>
In-Reply-To: <1348844071.1553.14.camel@x61.thuisdomein>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, levinsasha928@gmail.com, Feng Jin <joe.jin@oracle.com>, dan.carpenter@oracle.com



On 2012-09-28 22:54, Paul Bolle wrote:
> On Fri, 2012-09-28 at 11:43 +0800, Zhenzhong Duan wrote:
>> On 2012-09-27 19:35, Paul Bolle wrote:
>>> I think setting pages_to_unuse to zero here is not needed. It is
>>> initiated to zero in frontswap_shrink() and hasn't been touched since.
>>> See my patch at https://lkml.org/lkml/2012/9/27/250.
>> Yes, it's unneeded. But I didn't see warning as you said in above link
>> when run 'make V=1 mm/frontswap.o'.
> Not even before applying your patch? Anyhow, after applying your patch
> the warnings gone here too.
I tested both cases, no warning, also didn't see -Wmaybe-uninitialized 
when make.
My env is el5. gcc version 4.1.2 20080704 (Red Hat 4.1.2-52)
Maybe your gcc built in/implicit spec use that option?
thanks
zduan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
