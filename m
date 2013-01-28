Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E872E6B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 01:23:21 -0500 (EST)
Date: Mon, 28 Jan 2013 15:23:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Message-ID: <20130128062316.GI3321@blaptop>
References: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: psz@maths.usyd.edu.au, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 25, 2013 at 08:53:24PM +1100, paul.szabo@sydney.edu.au wrote:
> Dear Minchan,
> 
> > So what's the effect for user?
> > ...
> > It seems you saw old kernel.
> > ...
> > Current kernel includes ...
> > So I think we don't need this patch.
> 
> As I understand now, my patch is "right" and needed for older kernels;
> for newer kernels, the issue has been fixed in equivalent ways; it was
> an oversight that the change was not backported; and any justification
> you need, you can get from those "later better" patches.

I don't know your problem because you didn't write down your problem in
changelog. Anyway, If you want to apply it into older kernel,
please read Documentation/stable_kernel_rules.txt.

In summary,

1. Define your problem.
2. Apply your fix to see the problem goes away in older kernel.
3. If so, write the problem and effect in changelog
4. Send it to stable maintainers and mm maintainer

That's all.

> 
> I asked:
> 
>   A question: what is the use or significance of vm_highmem_is_dirtyable?
>   It seems odd that it would be used in setting limits or threshholds, but
>   not used in decisions where to put dirty things. Is that so, is that as
>   should be? What is the recommended setting of highmem_is_dirtyable?
> 
> The silence is deafening. I guess highmem_is_dirtyable is an aberration.

I hope this helps you find primary reason of your problem.
git show 195cf453


> 
> Thanks, Paul
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
