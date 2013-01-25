Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E6A0F6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 04:53:42 -0500 (EST)
Date: Fri, 25 Jan 2013 20:53:24 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, psz@maths.usyd.edu.au
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Minchan,

> So what's the effect for user?
> ...
> It seems you saw old kernel.
> ...
> Current kernel includes ...
> So I think we don't need this patch.

As I understand now, my patch is "right" and needed for older kernels;
for newer kernels, the issue has been fixed in equivalent ways; it was
an oversight that the change was not backported; and any justification
you need, you can get from those "later better" patches.

I asked:

  A question: what is the use or significance of vm_highmem_is_dirtyable?
  It seems odd that it would be used in setting limits or threshholds, but
  not used in decisions where to put dirty things. Is that so, is that as
  should be? What is the recommended setting of highmem_is_dirtyable?

The silence is deafening. I guess highmem_is_dirtyable is an aberration.

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
