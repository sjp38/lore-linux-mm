Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5469E6B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 04:55:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so8149062dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 01:55:48 -0700 (PDT)
Message-ID: <4FB0C888.8070805@gmail.com>
Date: Mon, 14 May 2012 16:55:36 +0800
From: Cong Wang <xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/10] shmem: replace page if mapping excludes its zone
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils> <alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1205120453210.28861@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephane Marchesin <marcheu@chromium.org>, Andi Kleen <andi@firstfloor.org>, Dave Airlie <airlied@gmail.com>, Daniel Vetter <ffwll.ch@google.com>, Rob Clark <rob.clark@linaro.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/12/2012 07:59 PM, Hugh Dickins wrote:
> +	VM_BUG_ON(!PageLocked(oldpage));
> +	__set_page_locked(newpage);
> +	VM_BUG_ON(!PageUptodate(oldpage));
> +	SetPageUptodate(newpage);
> +	VM_BUG_ON(!PageSwapBacked(oldpage));
> +	SetPageSwapBacked(newpage);
> +	VM_BUG_ON(!swap_index);
> +	set_page_private(newpage, swap_index);
> +	VM_BUG_ON(!PageSwapCache(oldpage));
> +	SetPageSwapCache(newpage);
> +

Are all of these VM_BUG_ON's necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
