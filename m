From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <11041923.1212400091150.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 2 Jun 2008 18:48:11 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: <4843903F.1090009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <4843903F.1090009@linux.vnet.ibm.com>
 <4841886A.1000901@linux.vnet.ibm.com> <48413482.5080409@linux.vnet.ibm.com> <48407DC3.8060001@linux.vnet.ibm.com> <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com> <25360008.1212199156779.kamezawa.hiroyu@jp.fujitsu.com> <26479923.1212245220415.kamezawa.hiroyu@jp.fujitsu.com> <5049235.1212280513897.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

>Why don't we add soft limits, so that we don't have to go to the kernel and
>change limits frequently. One missing piece in the memory controller is that 
we
>don't shrink the memory controller when limits change or when tasks move. I
>think soft limits is a better solution.
>
My code adds shirinking_at_limit_change. I'm now try to write migrate_resouces
_at_task_move. (But seems not so easy to be implemented in 
clean/fast way.)

I have no objection to soft-limit if it's easy to be implemented. (I wrote
my explanation was just an example and we could add more knobs.) 
_But_ I think that something to control multiple cgroups with regard to hierar
chy under some policy never be a simple one. Adding some knobs for each cgroup
s to do soft-limit will be simple one if no hirerachy.

Memory controller's  difference from scheduler's hirerachy is that we have to 
do multilevel page reclaim with feedback under some policy (not only one..). 
Even without hierarhcy, we _did_ make the kernel's LRU logic more complicated.
But we can get a help from the middleware here, I think.

My goal is never to make cgroup slow or complicated. If it's slow, 
I'd like to say "ok, please use VMware.It's simpler and enough fast for you." 
"How fast it works rather than Hardware-Virtualization" is the most
important for me. It should be much more faster.

>Thanks for patiently explaining all of this.
>
Thanks, I'm sorry for my poor explanation skill.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
