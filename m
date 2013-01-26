Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 419E36B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 15:23:49 -0500 (EST)
Date: Sun, 27 Jan 2013 07:23:18 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301262023.r0QKNIaK029258@como.maths.usyd.edu.au>
Subject: Re: Bug#695182: [PATCH] Subtract min_free_kbytes from dirtyable memory
In-Reply-To: <20130126074444.GA28833@elie.Belkin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jrnieder@gmail.com
Cc: 695182@bugs.debian.org, ben@decadent.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org

Dear Jonathan,

>> If you can identify where it was fixed then your patch for older
>> versions should go to stable with a reference to the upstream fix (see
>> Documentation/stable_kernel_rules.txt).
>
> How about this patch?
>
> It was applied in mainline during the 3.3 merge window, so kernels
> newer than 3.2.y shouldn't need it.
>
> ...
> commit ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d upstream.
> ...

Yes, I beleive that is the correct patch, surely better than my simple
subtraction of min_free_kbytes.

Noting, that this does not "solve" all problems, the latest 3.8 kernel
still crashes with OOM:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1098961/comments/18

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
