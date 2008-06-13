Message-ID: <485241AE.4030300@cn.fujitsu.com>
Date: Fri, 13 Jun 2008 17:45:18 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit
 architectures
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>	<4850070F.6060305@gmail.com>	<20080611121510.d91841a3.akpm@linux-foundation.org>	<485032C8.4010001@gmail.com>	<20080611134323.936063d3.akpm@linux-foundation.org>	<485055FF.9020500@gmail.com>	<20080611155530.099a54d6.akpm@linux-foundation.org>	<4850BE9B.5030504@linux.vnet.ibm.com>	<4850E3BC.308@gmail.com> <20080612020235.29a81d7c.akpm@linux-foundation.org> <485156B8.5070709@gmail.com> <48523FC5.4040900@linux.vnet.ibm.com>
In-Reply-To: <48523FC5.4040900@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: righi.andrea@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Andrea Righi wrote:
>> I've tested the following patch on a i386 box with my usual .config and
>> everything seems fine. I also tested allmodconfig and some randconfig
>> builds and
>> I've not seen any evident error.
>>
>> I'll repeat the tests tonight on a x86_64. Other architectures should be
>> tested
>> as well...
>>
>> Patch is against 2.6.25-rc5-mm3.
> 
> Hi, Andrea,
> 
> CC'ing linux-arch. I have a power box, but it's busy. I'll try and test your
> patch on it as soon as I can get hold of it.
> 
> 

It passes allmodconfig and a randconfig build on ia64, but I have no more access
to the machine to do more test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
