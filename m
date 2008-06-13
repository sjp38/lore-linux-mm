Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5D9bFOA020309
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 15:07:15 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5D9aVoe815330
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 15:06:31 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5D9bESG029077
	for <linux-mm@kvack.org>; Fri, 13 Jun 2008 15:07:15 +0530
Message-ID: <48523FC5.4040900@linux.vnet.ibm.com>
Date: Fri, 13 Jun 2008 15:07:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit
 architectures
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>	<4850070F.6060305@gmail.com>	<20080611121510.d91841a3.akpm@linux-foundation.org>	<485032C8.4010001@gmail.com>	<20080611134323.936063d3.akpm@linux-foundation.org>	<485055FF.9020500@gmail.com>	<20080611155530.099a54d6.akpm@linux-foundation.org>	<4850BE9B.5030504@linux.vnet.ibm.com>	<4850E3BC.308@gmail.com> <20080612020235.29a81d7c.akpm@linux-foundation.org> <485156B8.5070709@gmail.com>
In-Reply-To: <485156B8.5070709@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
> I've tested the following patch on a i386 box with my usual .config and
> everything seems fine. I also tested allmodconfig and some randconfig
> builds and
> I've not seen any evident error.
> 
> I'll repeat the tests tonight on a x86_64. Other architectures should be
> tested
> as well...
> 
> Patch is against 2.6.25-rc5-mm3.

Hi, Andrea,

CC'ing linux-arch. I have a power box, but it's busy. I'll try and test your
patch on it as soon as I can get hold of it.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
