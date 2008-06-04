Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m548xY2U021898
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 09:59:34 +0100
Received: from an-out-0708.google.com (anab36.prod.google.com [10.100.53.36])
	by zps37.corp.google.com with ESMTP id m548xWGR020520
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 01:59:33 -0700
Received: by an-out-0708.google.com with SMTP id b36so512288ana.21
        for <linux-mm@kvack.org>; Wed, 04 Jun 2008 01:59:32 -0700 (PDT)
Message-ID: <6599ad830806040159o648392a1l3dbd84d9c765a847@mail.gmail.com>
Date: Wed, 4 Jun 2008 01:59:32 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
In-Reply-To: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Kame,

I like the idea of keeping the kernel simple, and moving more of the
intelligence to userspace.

It may need the kernel to expose a bit more in the way of VM details,
such as memory pressure, OOM notifications, etc, but as long as
userspace can respond quickly to memory imbalance, it should work
fine. We're doing something a bit similar using cpusets and fake NUMA
at Google - the principle of juggling memory between cpusets is the
same, but the granularity is much worse :-)

On Tue, Jun 3, 2008 at 9:58 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  - supported hierarchy_model parameter.
>   Now, no_hierarchy and hardwall_hierarchy is implemented.

Should we try to support hierarchy and non-hierarchy cgroups in the
same tree? Maybe we should just enforce the restrictions that:

- the hierarchy mode can't be changed on a cgroup if you have children
or any non-zero usage/limit
- a cgroup inherits its parent's hierarchy mode.


>  - parent overcommits all children

I'm not sure that "overcommits" is the right word here - specifically,
the model ensures that a parent can't overcommit its children beyond
its limit.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
