Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m27D9g0j000748
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 05:09:42 -0800
Received: from py-out-1112.google.com (pyha77.prod.google.com [10.34.228.77])
	by zps37.corp.google.com with ESMTP id m27D9fDf016255
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 05:09:42 -0800
Received: by py-out-1112.google.com with SMTP id a77so734675pyh.35
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 05:09:41 -0800 (PST)
Message-ID: <6599ad830803070509v1ec83aeet9f63bfd61a00ef19@mail.gmail.com>
Date: Fri, 7 Mar 2008 05:09:32 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time (v2)
In-Reply-To: <47D13BF1.1060009@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
	 <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com>
	 <6599ad830803070426l22d78446t588691dedeeb490b@mail.gmail.com>
	 <47D13BF1.1060009@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 7, 2008 at 4:58 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  > Or rather, it's the other way around - cgroup_disable=cpuset will
>  > instead disable the "cpu" subsystem if "cpu" comes before "cpuset" in
>  > the subsystem list.
>  >
>
>  Would it? I must be missing something, since we do a strncmp with ss->name.
>  I would expect that to match whole strings.
>

No, strncmp only checks the first n characters - so in that case,
you'd be checking for !strncmp("cpuset", "cpu", 3), which will return
true

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
