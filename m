Message-Id: <483647AB.8090104@mxp.nes.nec.co.jp>
Date: Fri, 23 May 2008 13:27:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <48350F15.9070007@mxp.nes.nec.co.jp> <4835E55A.1000308@linux.vnet.ibm.com>
In-Reply-To: <4835E55A.1000308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hi.

On 2008/05/23 6:27 +0900, Balbir Singh wrote:
> Daisuke Nishimura wrote:
>> Hi.
>>
>> I updated my swapcgroup patch.
>>
>> Major changes from previous version(*1):
>> - Rebased on 2.6.26-rc2-mm1 + KAMEZAWA-san's performance
>>   improvement patchset v4.
>> - Implemented as a add-on to memory cgroup.
>>   So, there is no need to add a new member to page_cgroup now.
>> - (NEW)Modified vm_swap_full() to calculate the rate of
>>   swap usage per cgroup.
>>
>> Patchs:
>> - [1/4] add cgroup files
>> - [2/4] add member to swap_info_struct for cgroup
>> - [3/4] implement charge/uncharge
>> - [4/4] modify vm_swap_full for cgroup
>>
>> ToDo:
>> - handle force_empty.
>> - make it possible for users to select if they use
>>   this feature or not, and avoid overhead for users
>>   not using this feature.
>> - move charges along with task move between cgroups.
>>
> 
> Thanks for looking into this. Yamamoto-San is also looking into a swap
> controller. Is there a consensus on the approach?
> 
Not yet, but I think we should have some consensus each other
before going further.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
