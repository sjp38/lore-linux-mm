Message-ID: <48280DB0.7030608@openvz.org>
Date: Mon, 12 May 2008 13:28:16 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: make global var to be read_mostly
References: <20080509145631.408a9a67.kamezawa.hiroyu@jp.fujitsu.com> <4823E819.1000607@linux.vnet.ibm.com>
In-Reply-To: <4823E819.1000607@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, lizf@cn.fujitsu.com, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> KAMEZAWA Hiroyuki wrote:
>> An easy cut out from memcg: performance improvement patch set.
>> Tested on: x86-64/linux-2.6.26-rc1-git6
>>
>> Thanks,
>> -Kame
>>
>> ==
>> mem_cgroup_subsys and page_cgroup_cache should be read_mostly and
>> MEM_CGROUP_RECLAIM_RETRIES can be just a fixed number.
>>
>> Changelog:
>>   * makes MEM_CGROUP_RECLAIM_RETRIES to be a macro
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>>
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 

Acked-by: Pavel Emelyanov <xemul@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
