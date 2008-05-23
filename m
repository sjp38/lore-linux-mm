Message-Id: <48362795.9020709@mxp.nes.nec.co.jp>
Date: Fri, 23 May 2008 11:10:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] swapcgroup(v2)
References: <48350F15.9070007@mxp.nes.nec.co.jp> <20080522164421.84849565.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080522164421.84849565.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On 2008/05/22 16:44 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 May 2008 15:13:41 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
>> Hi.
>>
>> I updated my swapcgroup patch.
>>
> seems good in general.
> 
>
Thanks :-)
 
>> ToDo:
>> - handle force_empty.
> 
> Without this, we can do rmdir() against cgroup with swap. right ?
> 
You are right.

There are some cases that cgroup dir cannot be removed
because there remains some swap usage
even when no tasks remain in the dir.
In such cases, the only way to remove the dir is currently
to do swapoff.

So, I think this is the most important todo.

>> - make it possible for users to select if they use
>>   this feature or not, and avoid overhead for users
>>   not using this feature.
>> - move charges along with task move between cgroups.
>>
> I think memory-controller's anon pages should also do this....


> But how do you think about shared entries ?
> 
Yes.
This is a big problem. I don't have any practical idea yet,
but at least I think it should be avoided for some shared
entry to be charged to different groups.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
