Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5342A6B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 02:21:15 -0400 (EDT)
Received: by fxm9 with SMTP id 9so2387160fxm.38
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 23:21:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090612143429.76ef2357.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI>
	 <4A31C258.2050404@cn.fujitsu.com>
	 <20090612115501.df12a457.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090612124408.721ba2ae.kamezawa.hiroyu@jp.fujitsu.com>
	 <4A31D326.3030206@cn.fujitsu.com>
	 <20090612143429.76ef2357.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 12 Jun 2009 09:21:52 +0300
Message-ID: <84144f020906112321x9912476sb42b5d811741e646@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix page_cgroup fatal error in FLATMEM
	(Was Re: boot panic with memcg enabled
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 8:34 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, SLAB is configured in very early stage and it can be used in
> init routine now.
>
> But replacing alloc_bootmem() in FLAT/DISCONTIGMEM's page_cgroup()
> initialization breaks the allocation, now.
> (Works well in SPARSEMEM case...it supports MEMORY_HOTPLUG and
> =A0Size of page_cgroup is in reasonable size (< 1 << MAX_ORDER.)
>
> This patch revive FLATMEM+memory cgroup by using alloc_bootmem.
>
> In future,
> We stop to support FLATMEM (if no users) or rewrite codes for flatmem
> completely. But this will adds more messy codes and (big) overheads.
>
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

Do you want me to push this to Linus or will you take care of it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
