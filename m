Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7U565eG005443
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 01:06:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7U5650e260100
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 23:06:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7U564a9029685
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 23:06:04 -0600
Message-ID: <44F51CB7.4010504@cn.ibm.com>
Date: Wed, 30 Aug 2006 13:05:59 +0800
From: Yao Fei Zhu <walkinair@cn.ibm.com>
Reply-To: walkinair@cn.ibm.com
MIME-Version: 1.0
Subject: Re: Swap file or device can't be recognized by kernel built with
 64K pages.
References: <44F50940.1010204@cn.ibm.com>
In-Reply-To: <44F50940.1010204@cn.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: walkinair@cn.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, havelblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Yao Fei Zhu wrote:

> Problem description:
> swap file or device can't be recognized by kernel built with 64K pages.
>
> Hardware Environment:
>    Machine type (p650, x235, SF2, etc.): B70+
>    Cpu type (Power4, Power5, IA-64, etc.): POWER5+
> Software Environment:
>    OS : SLES10 GMC
>    Kernel: 2.6.18-rc5
> Additional info:
>
> tc1:~ # uname -r
> 2.6.18-rc5-ppc64
>
> tc1:~ # zcat /proc/config.gz | grep 64K
> CONFIG_PPC_64K_PAGES=y
>
> tc1:~ # mkswap ./swap.file
> Assuming pages of size 65536 (not 4096)
> Setting up swapspace version 0, size = 4294901 kB

Should use mkswap -v1 to create a new style swap area.

>
> tc1:~ # swapon ./swap.file
> swapon: ./swap.file: Invalid argument
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
