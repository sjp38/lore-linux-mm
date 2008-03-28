Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m2SE6sl2026511
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 14:06:55 GMT
Received: from py-out-1112.google.com (pyef47.prod.google.com [10.34.157.47])
	by zps18.corp.google.com with ESMTP id m2SE6qf9021993
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 07:06:54 -0700
Received: by py-out-1112.google.com with SMTP id f47so287510pye.8
        for <linux-mm@kvack.org>; Fri, 28 Mar 2008 07:06:52 -0700 (PDT)
Message-ID: <6599ad830803280706j54376243if56ccca0281f685d@mail.gmail.com>
Date: Fri, 28 Mar 2008 07:06:52 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
In-Reply-To: <47ECEA8F.5060505@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
	 <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com>
	 <47ECE662.3060506@linux.vnet.ibm.com>
	 <47ECEA8F.5060505@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28, 2008 at 5:54 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  Thinking more, I don't think it makes sense for us to overload task_lock() to do
>  the mm->owner handling (we don't want to mix lock domains). task_lock() is used
>  for several things
>
>  1. We don't want to make task_lock() rules more complicated by having it protect
>  an mm member to save space
>  2. We don't want more contention on task_lock()
>

This isn't to save space, it's to provide correctness. We *have* to
hold task_lock(new_owner) before setting mm->owner = new_owner,
otherwise we have no guarantee that new_owner is still a user of mm.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
