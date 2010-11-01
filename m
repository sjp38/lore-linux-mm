Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3570D8D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 19:11:47 -0400 (EDT)
Received: by iwn38 with SMTP id 38so6895896iwn.14
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 16:11:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1011012030150.12889@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1011012030150.12889@swampdragon.chaosbits.net>
Date: Tue, 2 Nov 2010 08:11:42 +0900
Message-ID: <AANLkTimL7Rbbf_7YxkJrxQPzb7v=J4Zg9=ZMV2tkHTAN@mail.gmail.com>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.or, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 2, 2010 at 4:35 AM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi (please CC me on replies),
>
> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then
> followed by memset() to zero the memory. This can be more efficiently
> achieved by using kzalloc() and vzalloc().
>
>
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
