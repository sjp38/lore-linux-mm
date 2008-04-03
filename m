From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Make the memory controller more desktop responsive
Date: Thu, 03 Apr 2008 15:14:32 +0530
Message-ID: <47F4A700.3080307@linux.vnet.ibm.com>
References: <20080403093253.8944.10168.sendpatchset@localhost.localdomain> <20080403184351.42de4f56.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758337AbYDCJpT@vger.kernel.org>
In-Reply-To: <20080403184351.42de4f56.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-Id: linux-mm.kvack.org

KAMEZAWA Hiroyuki wrote:
> On Thu, 03 Apr 2008 15:02:53 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> This patch makes the memory controller more responsive on my desktop.
>>
>> Here is what the patch does
>>
>> 1. Reduces the number of retries to 2. We had 5 earlier, since we
>>    were controlling swap cache as well. We pushed data from mappings
>>    to swap cache and we needed additional passes to clear out the cache.
> 
> Hmm, what this change improves ?
> I don't want to see OOM.
> 

I had set it to 5 earlier, since the swap cache came back to our memory
controller, where it was accounted. I have not seen OOM with it on my desktop,
but at some point if the memory required is so much that we cannot fulfill it,
we do OOM. I have not seen any OOM so far with these changes.

>> 2. It sets all cached pages as inactive. We were by default marking
>>    all pages as active, thus forcing us to go through two passes for
>>    reclaiming pages
> Agreed.
> 
>> 3. Removes congestion_wait(), since we already have that logic in
>>    do_try_to_free_pages()
>>
> Agreed.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
