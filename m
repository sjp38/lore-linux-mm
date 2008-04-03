From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v6)
Date: Thu, 03 Apr 2008 22:45:09 +0530
Message-ID: <47F5109D.8060606@linux.vnet.ibm.com>
References: <20080403073043.3563.63717.sendpatchset@localhost.localdomain> <6599ad830804030845m71d56d88u3508a252fc134ba5@mail.gmail.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762634AbYDCRRt@vger.kernel.org>
In-Reply-To: <6599ad830804030845m71d56d88u3508a252fc134ba5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Paul Menage wrote:
> On Thu, Apr 3, 2008 at 12:30 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  +         This option enables mm_struct's to have an owner. The advantage
>>  +         of this approach is that it allows for several independent memory
>>  +         based cgorup controllers to co-exist independently without too
> 
> cgorup -> cgroup
> 

yes, typo

>>  +       if (need_mm_owner_callback) {
>>  +               int i;
>>  +               for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>>  +                       struct cgroup_subsys *ss = subsys[i];
>>  +                       oldcgrp = task_cgroup(old, ss->subsys_id);
>>  +                       newcgrp = task_cgroup(new, ss->subsys_id);
>>  +                       if (oldcgrp == newcgrp)
>>  +                               continue;
>>  +                       if (ss->mm_owner_changed)
>>  +                               ss->mm_owner_changed(ss, oldcgrp, newcgrp);
> 
> Even better, maybe just pass in the relevant cgroup_subsys_state
> objects here, rather than the cgroup objects?
> 

Is that better than passing the cgroups? All the callbacks I see usually pass
either task_struct or cgroup. Won't it be better, consistent use of API to pass
either of those?

>>         css_get(&mem->css);
>>  -       rcu_assign_pointer(mm->mem_cgroup, mem);
>>         css_put(&old_mem->css);
> 
> These get/put calls are now unwanted?
> 

Yes, will remove them

> Could you also add comments in mm_need_new_owner(), in particular the
> reason for checking for delay_group_leader() ?

Yep, will do

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
