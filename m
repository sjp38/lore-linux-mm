Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BA95A6B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 02:00:25 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so1148540pbc.16
        for <linux-mm@kvack.org>; Sat, 23 Feb 2013 23:00:24 -0800 (PST)
Message-ID: <5129BA82.5070907@gmail.com>
Date: Sun, 24 Feb 2013 15:00:18 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Support variable-sized huge pages
References: <1359620590.1391.5.camel@kernel> <20130131105227.GI30577@one.firstfloor.org>
In-Reply-To: <20130131105227.GI30577@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>

On 01/31/2013 06:52 PM, Andi Kleen wrote:
> On Thu, Jan 31, 2013 at 02:23:10AM -0600, Ric Mason wrote:
>> Hi all,
>>
>> It seems that Andi's "Support more pagesizes for
>> MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
>> patch, x86 will support 2MB and 1GB huge pages. But I just see
>> hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
>> Where is 1GB huge pages?
> 1GB pages are only supported under 64bit kernels, and also
> only if you allocate them explicitely with boot options.

It seem that before your patch, we also can set mutiple hugepagesz, but 
hugetlbfs just mount default size, correct? IIUC, how can different size 
huge pages be used? If set mutiple hugepagesz, which one is default size?

>
> -Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
