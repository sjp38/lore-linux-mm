Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m316m2k5025612
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 07:48:03 +0100
Received: from mu-out-0910.google.com (muew8.prod.google.com [10.102.174.8])
	by zps38.corp.google.com with ESMTP id m316liZk031226
	for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:48:01 -0700
Received: by mu-out-0910.google.com with SMTP id w8so3182662mue.4
        for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:48:01 -0700 (PDT)
Message-ID: <6599ad830803312348u3ee4d815i2e24c130978f8e04@mail.gmail.com>
Date: Mon, 31 Mar 2008 23:48:00 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
In-Reply-To: <47F1D4F3.3040207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain>
	 <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com>
	 <47F1D4F3.3040207@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 31, 2008 at 11:23 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>  > Here we'll want to call vm_cgroup_update_mm_owner(), to adjust the
>  > accounting. (Or if in future we end up with more than a couple of
>  > subsystems that want notification at this time, we'll want to call
>  > cgroup_update_mm_owner() and have it call any interested subsystems.
>  >
>
>  I don't think we need to adjust accounting, since only mm->owner is changing and
>  not the cgroup to which the task/mm belongs. Do we really need to notify? I
>  don't want to do any notifications under task_lock().

It's possible but unlikely that the new owner is in a different cgroup.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
