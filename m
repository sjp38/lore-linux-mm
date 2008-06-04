Date: Wed, 4 Jun 2008 18:15:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
Message-Id: <20080604181528.f4c94743.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830806040159o648392a1l3dbd84d9c765a847@mail.gmail.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806040159o648392a1l3dbd84d9c765a847@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2008 01:59:32 -0700
"Paul Menage" <menage@google.com> wrote:

> Hi Kame,
> 
> I like the idea of keeping the kernel simple, and moving more of the
> intelligence to userspace.
> 
thanks.

> It may need the kernel to expose a bit more in the way of VM details,
> such as memory pressure, OOM notifications, etc, but as long as
> userspace can respond quickly to memory imbalance, it should work
> fine. We're doing something a bit similar using cpusets and fake NUMA
> at Google - the principle of juggling memory between cpusets is the
> same, but the granularity is much worse :-)
> 
yes, next problem is adding interfaces. but we have to investigate
what is principal.


> On Tue, Jun 3, 2008 at 9:58 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >  - supported hierarchy_model parameter.
> >   Now, no_hierarchy and hardwall_hierarchy is implemented.
> 
> Should we try to support hierarchy and non-hierarchy cgroups in the
> same tree? Maybe we should just enforce the restrictions that:
> 
> - the hierarchy mode can't be changed on a cgroup if you have children
> or any non-zero usage/limit
> - a cgroup inherits its parent's hierarchy mode.
> 
Ah, my patch does it (I think).  explanation is bad.

- mem cgroup's mode can be changed against ROOT node which has no children.
- a child inherits parent's mode.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
