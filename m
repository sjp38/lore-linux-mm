Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id DF27C6B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 03:58:03 -0500 (EST)
Message-ID: <510A31F7.8030005@huawei.com>
Date: Thu, 31 Jan 2013 16:57:27 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: Support variable-sized huge pages
References: <1359620590.1391.5.camel@kernel>
In-Reply-To: <1359620590.1391.5.camel@kernel>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>

On 2013/1/31 16:23, Ric Mason wrote:

> Hi all,
> 
> It seems that Andi's "Support more pagesizes for
> MAP_HUGETLB/SHM_HUGETLB" patch has already merged. According to the
> patch, x86 will support 2MB and 1GB huge pages. But I just see 
> hugepages-2048kB under /sys/kernel/mm/hugepages/ on my x86_32 PAE desktop.
> Where is 1GB huge pages?

Hi Ric,
By default only has 2M huge pages, you can specify "hugepagesz=1G hugepages=xx" in boot option,
then you can see: /sys/kernel/mm/hugepages/hugepages-1048576kB.

Thanks,
Jianguo Wu

> 
> Regards,
> Ric  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
