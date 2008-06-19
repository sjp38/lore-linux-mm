From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <7438228.1213882709934.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 19 Jun 2008 22:38:29 +0900 (JST)
Subject: Re: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
In-Reply-To: <485A5160.5070901@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <485A5160.5070901@linux.vnet.ibm.com>
 <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com> <4859CEE7.9030505@linux.vnet.ibm.com> <20080619122429.138a1d32.kamezawa.hiroyu@jp.fujitsu.com> <20080619192227.972ded64.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, menage@google.com, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>Date: 	Thu, 19 Jun 2008 18:00:24 +0530
>From: Balbir Singh <balbir@linux.vnet.ibm.com>

>> [root@iridium kamezawa]# ulimit -s unlimited
>> [root@iridium kamezawa]# cat /opt/cgroup/test/memrlimit.usage_in_bytes
>> 72368128
>> [root@iridium kamezawa]#
>
>Aaah.. I see.. I had it in place earlier, but moved them to may_expand_vm() o
n
>review suggestions. I can move it out or try to unroll when things fail. I'll
>experiment a bit more. Is there any particular method you prefer?
>
Anywhere... but...IMHO, where the rlimit does charge will be a candidate.
But doing that may make the code ugly, I'm not sure now.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
