Message-Id: <47E89FC4.4090105@mxp.nes.nec.co.jp>
Date: Tue, 25 Mar 2008 15:46:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] another swap controller for cgroup
References: <20080317020407.8512E1E7995@siro.lan> <47DE2894.6010306@mxp.nes.nec.co.jp> <47E79A26.3070401@mxp.nes.nec.co.jp> <47E79CF0.6040308@linux.vnet.ibm.com>
In-Reply-To: <47E79CF0.6040308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: yamamoto@valinux.co.jp, minoura@valinux.co.jp, Linux MM <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Daisuke Nishimura wrote:
>> Daisuke Nishimura wrote:
>>> Hi, Yamamoto-san.
>>>
>>> I'm reviewing and testing your patch now.
>>>
>> In building kernel infinitely(in a cgroup of
>> memory.limit=64M and swap.limit=128M, with swappiness=100),
>> almost all of the swap (1GB) is consumed as swap cache
>> after a day or so.
>> As a result, processes are occasionally OOM-killed even when
>> the swap.usage of the group doesn't exceed the limit.
>>
>> I don't know why the swap cache uses up swap space.
>> I will test whether a similar issue happens without your patch.
>> Do you have any thoughts?
>>
>>
>> BTW, I think that it would be better, in the sence of
>> isolating memory resource, if there is a framework
>> to limit the usage of swap cache.
> 
> We had this earlier, but dropped it later due to issues related to swap
> readahead and assigning the pages to the correct cgroup.
> 
Yes, I know.

In my swap subsystem posted before, I charge swap entries
and remember to which cgroup each swap entries is charged
in an array of pointers. So swap caches is charged as swap
not memory, and swap usage including swap cache can be accounted.

There may be better solution, and one of the issue of
my implementation is swap_cgroup_chage() returns error
before reclaiming swap entries which are only used
by swap caches.
I'm considering this issue now.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
