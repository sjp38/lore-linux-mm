Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m1F5UMAn014598
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 05:30:23 GMT
Received: from py-out-1112.google.com (pyhb50.prod.google.com [10.34.229.50])
	by zps76.corp.google.com with ESMTP id m1F5UK11023100
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 21:30:21 -0800
Received: by py-out-1112.google.com with SMTP id b50so678450pyh.30
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 21:30:20 -0800 (PST)
Message-ID: <6599ad830802142130h529ecd59w8f9e4e761d4fe20c@mail.gmail.com>
Date: Thu, 14 Feb 2008 21:30:19 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under memory pressure
In-Reply-To: <47B520B6.2020101@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	 <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
	 <47B3F073.1070804@linux.vnet.ibm.com>
	 <20080214174236.aa2aae9b.kamezawa.hiroyu@jp.fujitsu.com>
	 <47B406E4.9060109@linux.vnet.ibm.com>
	 <6599ad830802142017g7cdb1b9cid8bbc8cb97e2df68@mail.gmail.com>
	 <47B51430.4090009@linux.vnet.ibm.com>
	 <20080215140732.8b2dc04e.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830802142116r1c942d78y7002d90c2690a498@mail.gmail.com>
	 <47B520B6.2020101@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2008 at 9:18 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Paul Menage wrote:
>  > On Thu, Feb 14, 2008 at 9:07 PM, KAMEZAWA Hiroyuki
>  > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  >>  We can free memory by just making memory.limit to smaller number.
>  >>  (This may cause OOM. If we added high-low watermark, making memory.high smaller
>  >>   can works well for memory freeing to some extent.)
>  >>
>  >
>  > What about if we want to apply memory pressure to a cgroup to push out
>  > unused memory, but not push out memory that it's actively using?
>
>  Both watermarks and reducing the limit will reclaim from the inactive list
>  first. The reclaim logic is the same as that of the per zone LRU. It would be
>  right to assume that both would push out unused memory first. Am I missing
>  something?
>

Doesn't the per-zone LRU logic try to keep the inactive list at a
certain percentage of memory? In which case you can't really tell from
the active/inactive stats for a cgroup how much of that memory it's
really using.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
