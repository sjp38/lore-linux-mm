Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 512CC6B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 10:50:51 -0400 (EDT)
Received: by pxi5 with SMTP id 5so2727452pxi.14
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:50:51 -0700 (PDT)
Date: Tue, 17 Aug 2010 23:42:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Export mlock information via smaps
Message-ID: <20100817144256.GC3884@barrios-desktop>
References: <201008171039.31070.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008171039.31070.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 10:39:31AM +0530, Nikanth Karthikesan wrote:
> Currently there is no way to find whether a process has locked its pages in
> memory or not. And which of the memory regions are locked in memory.
> 
> Add a new field to perms field 'l' to export this information. The information
> exported via maps file is not changed.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Cced Matt. 

It would be good if we have a such thing. 
In addtion, code itself looks good to me. :)

But I have a question. 
Why didn't you change /proc/map? 
Due to ABI? So then, Is it okay to change smaps ABI?

I don't know there is any well-known tool to use smap information. 
Maybe Matt have the answer. 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
