Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m317gmCA122772
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 17:42:48 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m317VZpw3817682
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 18:31:35 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m317VYxc025156
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 17:31:35 +1000
Message-ID: <47F1E3C1.6050802@linux.vnet.ibm.com>
Date: Tue, 01 Apr 2008 12:56:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain> <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com> <47F1D4F3.3040207@linux.vnet.ibm.com> <6599ad830803312348u3ee4d815i2e24c130978f8e04@mail.gmail.com>
In-Reply-To: <6599ad830803312348u3ee4d815i2e24c130978f8e04@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 31, 2008 at 11:23 PM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
>>  > Here we'll want to call vm_cgroup_update_mm_owner(), to adjust the
>>  > accounting. (Or if in future we end up with more than a couple of
>>  > subsystems that want notification at this time, we'll want to call
>>  > cgroup_update_mm_owner() and have it call any interested subsystems.
>>  >
>>
>>  I don't think we need to adjust accounting, since only mm->owner is changing and
>>  not the cgroup to which the task/mm belongs. Do we really need to notify? I
>>  don't want to do any notifications under task_lock().
> 
> It's possible but unlikely that the new owner is in a different cgroup.

Hmmm... that can never happen with thread groups, since mm->owner is
p->group_leader and that never exits unless all threads are gone (it can
explicitly change groups though). Without thread groups, the new owner can
belong to a different cgroup, so we might need notification.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
