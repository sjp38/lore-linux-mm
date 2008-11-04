Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id mA46FiMl023886
	for <linux-mm@kvack.org>; Tue, 4 Nov 2008 06:15:44 GMT
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by spaceape24.eur.corp.google.com with ESMTP id mA46FDnI004514
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:15:42 -0800
Received: by rv-out-0708.google.com with SMTP id f25so2851651rvb.32
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 22:15:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081031115241.1399d605.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081031115057.6da3dafd.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081031115241.1399d605.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 3 Nov 2008 22:15:41 -0800
Message-ID: <6599ad830811032215j3ce5dcc1g6d0c3e9439a004d@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/5] memcg : force_empty to do move account
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, hugh@veritas.com, taka@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Thu, Oct 30, 2008 at 6:52 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch provides a function to move account information of a page between
> mem_cgroups and rewrite force_empty to make use of this.

One part of this that wasn't clear to me - if a cgroup has a lot of
unmapped pagecache sitting around but no tasks, and we try to rmdir
it, then all the pagecache gets moved to the parent too? Or just the
stray mapped pages?

> @@ -597,7 +709,7 @@ static int mem_cgroup_charge_common(stru
>        prefetchw(pc);
>
>        mem = memcg;
> -       ret = mem_cgroup_try_charge(mm, gfp_mask, &mem);
> +       ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true);

Isn't this the same as the definition of mem_cgroup_try_charge()? So
you could leave it as-is?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
