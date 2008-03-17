Message-ID: <47DDE4C9.5040302@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 12:26:01 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] radix-tree page cgroup
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com> <47DDDDC6.2080808@cn.fujitsu.com>
In-Reply-To: <47DDDDC6.2080808@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +/*
>> + * Look up page_cgroup struct for struct page (page's pfn)
>> + * if (allocate == true), look up and allocate new one if necessary.
>> + * if (allocate == false), look up and return NULL if it cannot be found.
>> + */
>> +
> 
> It's confusing when NULL will be returned and when -EFXXX...
> 
> if (allocate == true) -EFXXX may still be returned ?
> 

Sorry, my comment is:

It's confusing when NULL will be returned and when -EFXXX... 

if (allocate == true), *NULL* may still be returned ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
