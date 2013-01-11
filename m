Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id F13516B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 19:47:29 -0500 (EST)
Date: Fri, 11 Jan 2013 11:46:06 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301110046.r0B0k6lR024284@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with partial workaround
In-Reply-To: <50EF4AD1.4060807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Dave,

> Your configuration has never worked.  This isn't a regression ...
> ... does not mean that we expect it to work.

Do you mean that CONFIG_HIGHMEM64G is deprecated, should not be used;
that all development is for 64-bit only?

> ... 64-bit kernels should basically be drop-in replacements ...

Will think about that. I know all my servers are 64-bit capable, will
need to check all my desktops.

---

I find it puzzling that there seems to be a sharp cutoff at 32GB RAM,
no problem under but OOM just over; whereas I would have expected
lowmem starvation to be gradual, with OOM occuring much sooner with
64GB than with 34GB. Also, the kernel seems capable of reclaiming
lowmem, so I wonder why does that fail just over the 32GB threshhold.
(Obviously I have no idea what I am talking about.)

---

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
