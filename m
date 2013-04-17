Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C5DD86B006E
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:16:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4D2973EE0C2
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:16:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3448145DE53
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:16:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AF7E45DDCF
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:16:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07BB21DB803F
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:16:43 +0900 (JST)
Received: from g01jpexchkw38.g01.fujitsu.local (g01jpexchkw38.g01.fujitsu.local [10.0.193.68])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B36031DB8038
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:16:42 +0900 (JST)
Message-ID: <516E4C3F.8040302@jp.fujitsu.com>
Date: Wed, 17 Apr 2013 16:16:15 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH v3] Reusing a resource structure allocated by
 bootmem
References: <516DEC34.7040008@jp.fujitsu.com> <alpine.DEB.2.02.1304161733340.14583@chino.kir.corp.google.com> <516E2305.3060705@jp.fujitsu.com> <alpine.DEB.2.02.1304162144320.3493@chino.kir.corp.google.com> <516E452A.7060703@jp.fujitsu.com> <alpine.DEB.2.02.1304162351300.5220@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1304162351300.5220@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hp.com, linuxram@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

2013/04/17 15:52, David Rientjes wrote:
> On Wed, 17 Apr 2013, Yasuaki Ishimatsu wrote:
>
>>> How much memory are we talking about?
>>
>> Hmm. I don't know correctly.
>>
>> Here is kernel message of my system. The message is shown by mem_init().
>>
>
> Do you have an estimate on the amount of struct resource memory that will
> be leaked if entire pages won't be freed?
>

I roughly estimated amount of memory which will leak as follows:

$ wc -l /proc/ioports
92 /proc/ioports
$ wc -l /proc/iomem
226 /proc/iomem

In my system, number of resource structures are 318 and
sizeof(struct resource) is 56 bytes. So even if all resource
structures are leaked, the size is 17 KiB.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
