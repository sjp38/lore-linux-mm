Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 9D8836B005A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 09:51:57 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4318372vbk.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 06:51:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120813134900.GE24248@dhcp22.suse.cz>
References: <20120813130906.GA24248@dhcp22.suse.cz>
	<CAJd=RBCJL+oPRZMNNmtwSWH6CM1fiUNh=X+Leuk25Lyd3uKB5Q@mail.gmail.com>
	<20120813134900.GE24248@dhcp22.suse.cz>
Date: Mon, 13 Aug 2012 21:51:56 +0800
Message-ID: <CAJd=RBAvGS_6JEQ5hMJYK7=W_MAvQ3DtBa=Y4uT1w4utiDub8g@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: do not use vma_hugecache_offset for vma_prio_tree_foreach
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On Mon, Aug 13, 2012 at 9:49 PM, Michal Hocko <mhocko@suse.cz> wrote:
>
> I will leave it as an excersise for the careful reader...

Is it too late for you to prepare a redelivery?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
