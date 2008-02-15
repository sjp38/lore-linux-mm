Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m1F4HRaD032410
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 04:17:27 GMT
Received: from py-out-1112.google.com (pyha78.prod.google.com [10.34.228.78])
	by zps18.corp.google.com with ESMTP id m1F4HQcV004879
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 20:17:26 -0800
Received: by py-out-1112.google.com with SMTP id a78so687822pyh.32
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 20:17:26 -0800 (PST)
Message-ID: <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
Date: Thu, 14 Feb 2008 20:17:25 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under memory pressure
In-Reply-To: <47B406E4.9060109@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	 <20080213151242.7529.79924.sendpatchset@localhost.localdomain>
	 <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
	 <47B3F073.1070804@linux.vnet.ibm.com>
	 <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
	 <47B406E4.9060109@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2008 at 1:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  > Probably backgound-reclaim patch will be able to help this soft-limit situation,
>  > if a daemon can know it should reclaim or not.
>  >
>
>  Yes, I agree. I might just need to schedule the daemon under memory pressure.
>

Can we also have a way to trigger a one-off reclaim (of a configurable
magnitude) from userspace? Having a background daemon doing it may be
fine as a default, but there will be cases when a userspace machine
manager knows better than the kernel how frequently/hard to try to
reclaim on a given cgroup.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
