Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 766D66B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 12:39:57 -0500 (EST)
MIME-Version: 1.0
In-Reply-To: <1262963603-21908-1-git-send-email-kirill@shutemov.name>
References: <1262963603-21908-1-git-send-email-kirill@shutemov.name>
Date: Fri, 8 Jan 2010 23:09:50 +0530
Message-ID: <661de9471001080939o55226976scd6e1fc28587a8e8@mail.gmail.com>
Subject: Re: [PATCH] memcg: typo in comment to mem_cgroup_print_oom_info()
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew@kvack.org, "Morton <akpm"@linux-foundation.org, linux-mm@kvack.org, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 8, 2010 at 8:43 PM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
> s/mem_cgroup_print_mem_info/mem_cgroup_print_oom_info/
>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Pavel Emelyanov <xemul@openvz.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4572907..0d78570 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1070,7 +1070,7 @@ static int mem_cgroup_count_children_cb(struct mem_=
cgroup *mem, void *data)
> =A0}
>
> =A0/**
> - * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in=
 read mode.
> + * mem_cgroup_print_oom_info: Called from OOM with tasklist_lock held in=
 read mode.
> =A0* @memcg: The memory cgroup that went over limit
> =A0* @p: Task that is going to be killed
> =A0*

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
