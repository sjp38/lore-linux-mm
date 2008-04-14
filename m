Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m3E7rg51021506
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 08:53:42 +0100
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps37.corp.google.com with ESMTP id m3E7rffZ026546
	for <linux-mm@kvack.org>; Mon, 14 Apr 2008 00:53:41 -0700
Received: by py-out-1112.google.com with SMTP id a25so1550871pyi.11
        for <linux-mm@kvack.org>; Mon, 14 Apr 2008 00:53:41 -0700 (PDT)
Message-ID: <6599ad830804140053y4bcdceeatc9763c1e8c1aaf44@mail.gmail.com>
Date: Mon, 14 Apr 2008 00:53:41 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] memcg: fix oops in oom handling
In-Reply-To: <20080414161428.27f3ee59.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4802FF10.6030905@cn.fujitsu.com>
	 <20080414161428.27f3ee59.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2008 at 12:14 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>  Paul, I have one confirmation. Lock hierarchy of
>         cgroup_lock()
>         ->      read_lock(&tasklist_lock)
>
>  is ok ? (I think this is ok.)

Should be fine, I think.

Have you built/booted with lockdep?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
