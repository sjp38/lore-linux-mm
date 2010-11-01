Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 628838D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 15:58:45 -0400 (EDT)
Received: by wyf23 with SMTP id 23so6052088wyf.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 12:58:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
Date: Tue, 2 Nov 2010 04:58:43 +0900
Message-ID: <AANLkTinLfkmEczRs_7aw8GFBEX_1Dzoh=R024_R1KY85@mail.gmail.com>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

2010/11/2 Jesper Juhl <jj@chaosbits.net>:
> Hi (please CC me on replies),
>
>
> Apologies to those who receive this multiple times. I screwed up the To:
> field in my original mail :-(
>
>
> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then
> followed by memset() to zero the memory. This can be more efficiently
> achieved by using kzalloc() and vzalloc().
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
