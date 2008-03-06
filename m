Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m260ZjJL026222
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 00:35:46 GMT
Received: from wr-out-0506.google.com (wrac46.prod.google.com [10.54.54.46])
	by zps37.corp.google.com with ESMTP id m260Zcrm019536
	for <linux-mm@kvack.org>; Wed, 5 Mar 2008 16:35:44 -0800
Received: by wr-out-0506.google.com with SMTP id c46so2086127wra.18
        for <linux-mm@kvack.org>; Wed, 05 Mar 2008 16:35:44 -0800 (PST)
Message-ID: <6599ad830803051635i3bf54d7yc61087a4bd8d2cff@mail.gmail.com>
Date: Wed, 5 Mar 2008 16:35:43 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC/PATCH] cgroup swap subsystem
In-Reply-To: <20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47CE36A9.3060204@mxp.nes.nec.co.jp> <47CE5AE2.2050303@openvz.org>
	 <Pine.LNX.4.64.0803051400000.22243@blonde.site>
	 <47CEAAB4.8070208@openvz.org>
	 <20080306093324.77c6d7f4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, containers@lists.osdl.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, Mar 5, 2008 at 4:33 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  Is this kind of new entry in mem_cgroup not good ?
>  ==
>  struct mem_cgroup {
>         ...
>         struct res_counter      memory_limit.
>         struct res_counter      swap_limit.
>         ..

I agree with this - main memory and swap memory are rather different
kinds of resources, with very different performance characteristics.
It should be possible to control them completely independently (e.g.
this job gets 100M of main memory, and doesn't swap at all).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
