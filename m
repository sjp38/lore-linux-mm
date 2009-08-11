Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED7CD6B005A
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 11:01:07 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7BEvJAK025219
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 20:27:19 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7BF11GE2363442
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 20:31:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7BF10lm013848
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 01:01:01 +1000
Date: Tue, 11 Aug 2009 20:30:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Help Resource Counters Scale better (v4)
Message-ID: <20090811150057.GY7176@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090811144405.GW7176@balbir.in.ibm.com> <4A81863A.2050504@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4A81863A.2050504@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Prarit Bhargava <prarit@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "menage@google.com" <menage@google.com>, andi.kleen@intel.com, Pavel Emelianov <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Prarit Bhargava <prarit@redhat.com> [2009-08-11 10:54:50]:

>
>
> Balbir Singh wrote:
>> Enhancement: Remove the overhead of root based resource counter accounting
>>
>>
>>   
>
> <snip>
>> Please test/review.
>>
>>   
> FWIW ...
>

Thanks for the testing!

> On a 64p/32G system running 2.6.31-git2-rc5, with RESOURCE_COUNTERS off,  
> "time make -j64" results in
>
> real    4m54.972s
> user    90m13.456s
> sys     50m19.711s
>
> On the same system, running 2.6.31-git2-rc5, with RESOURCE_COUNTERS on,
> plus Balbir's "Help Resource Counters Scale Better (v3)" patch, and this  
                                                     ^^^
                                        you mean (v4) right?
> patch, results in
>
> real    4m18.607s
> user    84m58.943s
> sys     50m52.682s
>

Without the patch and RESOURCE_COUNTERS do you see a big overhead. I'd
assume so, I am seeing it on my 24 way box that I have access to.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
