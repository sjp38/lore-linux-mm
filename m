Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id A33606B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 23:12:02 -0400 (EDT)
Message-ID: <51F9D1F6.4080001@jp.fujitsu.com>
Date: Wed, 31 Jul 2013 23:11:50 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH resend] drop_caches: add some documentation and info message
References: <1374842669-22844-1-git-send-email-mhocko@suse.cz> <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
In-Reply-To: <20130729135743.c04224fb5d8e64b2730d8263@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, bp@suse.de, dave@linux.vnet.ibm.com

>> --- a/fs/drop_caches.c
>> +++ b/fs/drop_caches.c
>> @@ -59,6 +59,8 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>>  	if (ret)
>>  		return ret;
>>  	if (write) {
>> +		printk(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
>> +		       current->comm, task_pid_nr(current), sysctl_drop_caches);
>>  		if (sysctl_drop_caches & 1)
>>  			iterate_supers(drop_pagecache_sb, NULL);
>>  		if (sysctl_drop_caches & 2)
> 
> How about we do
> 
> 	if (!(sysctl_drop_caches & 4))
> 		printk(....)
> 
> so people can turn it off if it's causing problems?

The best interface depends on the purpose. If you want to detect crazy application,
we can't assume an application co-operate us. So, I doubt this works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
