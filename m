Date: Thu, 22 May 2008 22:26:55 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 0/4] swapcgroup(v2)
Message-ID: <20080522222655.166657da@bree.surriel.com>
In-Reply-To: <48350F15.9070007@mxp.nes.nec.co.jp>
References: <48350F15.9070007@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Hugh Dickins <hugh@veritas.com>, "IKEDA, Munehiro" <m-ikeda@ds.jp.nec.com>
List-ID: <linux-mm.kvack.org>

On Thu, 22 May 2008 15:13:41 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I updated my swapcgroup patch.

I do not understand why this is useful.

With the other cgroup resource controllers, once a process
group reaches its limit, it is limited or punished in some
way.  For example, when it goes over its RSS limit, memory
is taken away.

However, once a cgroup reaches its swap limit, it is
rewarded, by allowing more of its pages to stay resident
in RAM, instead of having them swapped out.  

This, in turn, will cause the VM to evict pages from other, 
better behaving groups.  In short, the cgroup that has
"misbehaved" by reaching its limit causes other cgroups to
get punished.

Even worse is that a cgroup has NO CONTROL over how much
of its memory is kept in RAM and how much is swapped out.
This kind of decision is made on a system-wide basis by
the kernel, dependent on what other processes in the system
are doing. There also is no easy way for a cgroup to reduce
its swap use, unlike with other resources.

In what scenario would you use a resource controller that
rewards a group for reaching its limit?

How can the cgroup swap space controller help sysadmins
achieve performance or fairness goals on a system? 

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
