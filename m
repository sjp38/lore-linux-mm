Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25D686B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 02:21:45 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p7J6LPtf011684
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 11:51:25 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7J6LOLG2773130
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 11:51:24 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7J6LN2W019790
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 16:21:24 +1000
Message-ID: <4E4E00E3.7080306@linux.vnet.ibm.com>
Date: Fri, 19 Aug 2011 11:51:23 +0530
From: Raghavendra K T <raghukt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/1][cleanup] memcg: renaming of mem variable to memcg
References: <20110812070623.28939.4733.sendpatchset@oc5400248562.ibm.com> <20110817124339.GA10245@tiehlicka.suse.cz>
In-Reply-To: <20110817124339.GA10245@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Arend van Spriel <arend@broadcom.com>, Greg Kroah-Hartman <gregkh@suse.de>, "David S. Miller" <davem@davemloft.net>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, "John W. Linville" <linville@tuxdriver.com>, Mauro Carvalho Chehab <mchehab@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>

On 08/17/2011 06:13 PM, Michal Hocko wrote:
> Sorry for late reply
>
> On Fri 12-08-11 12:36:23, Raghavendra K T wrote:
>>   The memcg code sometimes uses "struct mem_cgroup *mem" and sometimes uses
>>   "struct mem_cgroup *memcg". This patch renames all mem variables to memcg in
>>   source file.
>>
>> Testing : Compile tested with following configurations.
>> 1) make defconfig ARCH=i386 + CONFIG_CGROUP_MEM_RES_CTLR=y
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
>>
>> Binary size Before patch
>> ========================
>>     text	   data	    bss	    dec	    hex	filename
>> 8911169	 520464	1884160	11315793	 acaa51	vmlinux
>>
>> Binary Size After patch
>> =======================
>>     text	   data	    bss	    dec	    hex	filename
>> 8911169	 520464	1884160	11315793	 acaa51	vmlinux
>
> It would be much nicer to see unchanged md5sum. I am not sure how much
> possible is this with current gcc or whether special command line
> parameters have to be used (at least !CONFIG_DEBUG_INFO* is necessary)
> but simple variable rename shouldn't be binary visible.
> I guess that a similar approach was used during 32b and 64b x86
> unification.
>
I agree,  I could get same MD5 sum only in N N N config case (3rd config).
  I am not sure whether we can get same Md5 after lines have been split.
Here is what I tried: static KBUILD_BUILD_TIMESTAMP 
KBUILD_BUILD_VERSION, initramfs source. strip vmlinux. (could not 
disable CONFIG_BUG).
I referred to 32nb 64b unification also, did not get much insight from 
there on same MD5.

>>
>> 2) make defconfig ARCH=i386 + CONFIG_CGROUP_MEM_RES_CTLR=y
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=n
>
> I would assume the same testing results as above
Yes
8908671	 519808	1884160	11312639	 ac9dff	vmlinux
>
>>
>> 3) make defconfig ARCH=i386  CONFIG_CGROUP_MEM_RES_CTLR=n
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=n
>
> ditto.

8878794	 517632	1880064	11276490	 ac10ca	vmlinux before and after
>
>>
>> Other sanity check:
>> Bootable configuration on x86 (T60p)  with  CONFIG_CGROUP_MEM_RES_CTLR=y
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED=y
>> is tesed with basic mounting of memcgroup, creation of child and parallel fault.
>> mkdir -p /cgroup
>> mount -t cgroup none /cgroup -o memory
>> mkdir /cgroup/0
>> echo $$>  /cgroup/0/tasks
>> time ./parallel_fault 2 100000 32
>>
>> real	0m0.025s
>> user	0m0.001s
>> sys	0m0.033s
>
> This looks like a random test. I wouldn't add it to the changelog.
Agree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
