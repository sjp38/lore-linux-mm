Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m2SB4JhO020103
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 11:04:19 GMT
Received: from py-out-1112.google.com (pyhb50.prod.google.com [10.34.229.50])
	by zps37.corp.google.com with ESMTP id m2SB4IXU025649
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 04:04:18 -0700
Received: by py-out-1112.google.com with SMTP id b50so217326pyh.30
        for <linux-mm@kvack.org>; Fri, 28 Mar 2008 04:04:17 -0700 (PDT)
Message-ID: <6599ad830803280404i475c9824i31741af5a8ebf376@mail.gmail.com>
Date: Fri, 28 Mar 2008 04:04:17 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
In-Reply-To: <47ECCE00.70803@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
	 <20080328195516.494edde3.kamezawa.hiroyu@jp.fujitsu.com>
	 <47ECCE00.70803@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28, 2008 at 3:52 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  > How about changing this css_get()/css_put() from accounting against mm_struct
>  > to accouting against task_struct ?
>  > It seems simpler way after this mm->owner change.
>
>  But the reason why we account the mem_cgroup is that we don't want the
>  mem_cgroup to be deleted. I hope you meant mem_cgroup instead of mm_struct.
>

If there are any tasks in the cgroup then the cgroup can't be deleted,
and hence the mem_cgroup is safe.

css_get()/css_put() is only needed when you have a reference from a
non-task object that needs to keep the mem_cgroup alive, which is no
longer the case for mm_struct once we have mm->owner.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
