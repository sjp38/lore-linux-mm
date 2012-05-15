Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id F0E8D6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:44:50 -0400 (EDT)
Received: by dakp5 with SMTP id p5so10397719dak.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 02:44:50 -0700 (PDT)
Message-ID: <4FB22589.9050406@gmail.com>
Date: Tue, 15 May 2012 17:44:41 +0800
From: Cong Wang <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils> <4FB0C888.8070805@gmail.com> <alpine.LSU.2.00.1205141219340.1623@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205141219340.1623@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <ffwll.ch@google.com>, Rob Clark <rob.clark@linaro.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/15/2012 03:42 AM, Hugh Dickins wrote:
> I'm not going to rush the incremental patch to fix this: need to think
> about it quietly first.
>
> If you're wondering what I'm talking about (sorry, I don't have time
> to explain more right now), take a look at comment and git history of
> line 2956 (in 3.4-rc7) of mm/memory.c:
> 	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
> I don't suppose anyone ever actually hit the bug in the years before
> we added that protection, but we still ought to guard against it,
> there and here in shmem_replace_page().
>

Ok, I have no objections.

Thanks for your patches anyway!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
