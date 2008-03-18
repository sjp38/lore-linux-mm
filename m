Message-ID: <47E05681.8020409@cn.fujitsu.com>
Date: Wed, 19 Mar 2008 08:55:45 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] memcg: speed up by percpu
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>	<20080314191852.50b4b569.kamezawa.hiroyu@jp.fujitsu.com>	<47DDDF7E.7030804@cn.fujitsu.com> <20080318102558.0da456e1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318102558.0da456e1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 17 Mar 2008 12:03:26 +0900
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>>> +static inline struct page_cgroup *
>>> +get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
>> This function is too big to be inline
>>
> I don't think so. This just does shift, mask, access to per-cpu.
> And enough benefit to make this to be inline.
> But ok, will check text size.
> 

Normally 1-line or 2-lines functions are good candidates for inline,
but others are usually not.

> Thanks,
> -Kame
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
