Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id C1288828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:40:22 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id q63so71795791pfb.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 14:40:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xp4si13919759pac.213.2016.01.12.14.40.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 14:40:21 -0800 (PST)
Date: Tue, 12 Jan 2016 14:40:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: If nr_new is 0 just return
Message-Id: <20160112144020.db1cd77e97e41d5c48024c3c@linux-foundation.org>
In-Reply-To: <1452339220-3457-1-git-send-email-nimisolo@gmail.com>
References: <1452339220-3457-1-git-send-email-nimisolo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nimisolo <nimisolo@gmail.com>
Cc: kuleshovmail@gmail.com, penberg@kernel.org, tony.luck@intel.com, mgorman@suse.de, tangchen@cn.fujitsu.com, weiyang@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat,  9 Jan 2016 06:33:40 -0500 nimisolo <nimisolo@gmail.com> wrote:

> If nr_new is 0 which means there's no region would be added,
> so just return to the caller.
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -588,6 +588,9 @@ repeat:
>  					       nid, flags);
>  	}
>  
> +	if (!nr_new)
> +		return 0;
> +
>  	/*
>  	 * If this was the first round, resize array and repeat for actual
>  	 * insertions; otherwise, merge and return.

hm, why?  Is there something actually wrong with the current code?

Under what circumstances does nr_new==0 actually happen?  Is it a bug
in the caller?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
