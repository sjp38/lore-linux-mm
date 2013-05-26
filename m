Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id CEFF36B00CC
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:00:07 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id o17so8002514oag.13
        for <linux-mm@kvack.org>; Sun, 26 May 2013 08:00:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51A21C63.4010606@gmail.com>
References: <1369298568-20094-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <51A16268.4000401@gmail.com> <51A21C63.4010606@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 26 May 2013 10:59:46 -0400
Message-ID: <CAHGf_=rq7vByQVmVGyFk51q_d=ftpjuMjNXSszcfHWmZMu6jjw@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm/memory-hotplug: fix lowmem count overflow when
 offline pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Jiang <liuj97@gmail.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

> Hi KOSAKI,
>         Could you please help to give more information on the background
> about why 32bit platforms with highmem can't support memory hot-removal?

It doesn't impossible. Just nobody did. I was playing these code as a
maintainer a while
and I saw all of patches doesn't handle highmem correctly. But I
didn't refuse because
I know it's not a regression.

> We are trying to enable memory hot-removal on some 32bit platforms with
> highmem, really appreciate your help here!

But, if you guys have a strong motivation, it's a very good news. I
have no objection not to mark it broken and accept your contributions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
