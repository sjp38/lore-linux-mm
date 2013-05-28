Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E52436B0032
	for <linux-mm@kvack.org>; Tue, 28 May 2013 03:16:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 28 May 2013 12:40:51 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6C6B91258051
	for <linux-mm@kvack.org>; Tue, 28 May 2013 12:48:13 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4S7G5KN5898718
	for <linux-mm@kvack.org>; Tue, 28 May 2013 12:46:06 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4S7G6tW028296
	for <linux-mm@kvack.org>; Tue, 28 May 2013 17:16:09 +1000
Date: Tue, 28 May 2013 15:16:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 1/6] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Message-ID: <20130528071601.GA11936@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369712253.3469.426.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369712253.3469.426.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Tue, May 28, 2013 at 04:37:33AM +0100, Ben Hutchings wrote:
>On Sun, 2013-05-26 at 13:58 +0800, Wanpeng Li wrote:
>> Changelog:
>>  v1 -> v2:
>> 	* show number of HighTotal before hotremove 
>> 	* remove CONFIG_HIGHMEM
>> 	* cc stable kernels
>> 	* add Michal reviewed-by
>> 
>> Logic memory-remove code fails to correctly account the Total High Memory 
>> when a memory block which contains High Memory is offlined as shown in the
>> example below. The following patch fixes it.
>> 
>> Stable for 2.6.24+.
>[...]
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>[...]
>
>This is not the correct way to request changes for stable.  See
>Documentation/stable_kernel_rules.txt

Ok, I will resend it. 

>
>Ben.
>
>-- 
>Ben Hutchings
>If at first you don't succeed, you're doing about average.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
