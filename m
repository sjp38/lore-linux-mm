Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m2H5Mncj030071
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 22:22:49 -0700
Received: from py-out-1112.google.com (pyef47.prod.google.com [10.34.157.47])
	by zps78.corp.google.com with ESMTP id m2H5Mm9R030206
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 22:22:49 -0700
Received: by py-out-1112.google.com with SMTP id f47so5703101pye.14
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 22:22:48 -0700 (PDT)
Message-ID: <6599ad830803162222t6c32f5a1qd4d0af4887dfa910@mail.gmail.com>
Date: Mon, 17 Mar 2008 13:22:48 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
In-Reply-To: <47DDFCEA.3030207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
	 <47DDCDA7.4020108@cn.fujitsu.com>
	 <6599ad830803161857r6d01f962vfd0f570e6124ab24@mail.gmail.com>
	 <47DDFCEA.3030207@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 1:08 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I understand the per-mm pointer overhead back to the cgroup. I don't understand
>  the part about adding a per-mm pointer back to the "owning" task. We already
>  have task->mm.

Yes, but we don't have mm->owner, which is what I was proposing -
mm->owner would be a pointer typically to the mm's thread group
leader. It would remove the need to have to have pointers for the
various different cgroup subsystems that need to act on an mm rather
than a task_struct, since then you could use
mm->owner->cgroups[subsys_id].

But this is kind of orthogonal to whether virtual address space limits
should be a separate cgroup subsystem.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
