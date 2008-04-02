From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Thu, 03 Apr 2008 00:23:34 +0530
Message-ID: <47F3D62E.4070808@linux.vnet.ibm.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760889AbYDBSyI@vger.kernel.org>
In-Reply-To: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Balbir Singh wrote:
> Changelog v3
> ------------
> 
> 1. Add mm->owner change callbacks using cgroups
> 
> This patch removes the mem_cgroup member from mm_struct and instead adds
> an owner. This approach was suggested by Paul Menage. The advantage of
> this approach is that, once the mm->owner is known, using the subsystem
> id, the cgroup can be determined. It also allows several control groups
> that are virtually grouped by mm_struct, to exist independent of the memory
> controller i.e., without adding mem_cgroup's for each controller,
> to mm_struct.
> 
> A new config option CONFIG_MM_OWNER is added and the memory resource
> controller selects this config option.
> 
> NOTE: This patch was developed on top of 2.6.25-rc5-mm1 and is applied on top
> of the memory-controller-move-to-own-slab patch (which is already present
> in the Andrew's patchset).
> 
> This patch also adds cgroup callbacks to notify subsystems when mm->owner
> changes. The mm_cgroup_changed callback is called with the task_lock()
> of the new task held and is called just prior to changing the mm->owner.
> 
> I am indebted to Paul Menage for the several reviews of this patchset
> and helping me make it lighter and simpler.
> 
> This patch was tested on a powerpc box.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Hi,

So far I've heard no objections or seen any review suggestions. Paul if you are
OK with this patch, I'll ask Andrew to include it in -mm.

People waiting on this patch

1. Pekka Enberg for revoke* syscalls
2. Serge Hallyn for swap namespaces
3. Myself to implement the rlimit controller for cgroups

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
