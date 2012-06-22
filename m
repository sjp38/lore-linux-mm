Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 413F36B0149
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 03:13:50 -0400 (EDT)
Message-ID: <4FE41B3F.6090106@kernel.org>
Date: Fri, 22 Jun 2012 16:14:07 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: mmotm 2012-06-21-16-20 uploaded
References: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
In-Reply-To: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hi Andrew,

On 06/22/2012 08:21 AM, akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2012-06-21-16-20 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> It contains the following patches against 3.5-rc3:
> (patches marked "*" will be included in linux-next)
> 
>   origin.patch
> * selinux-fix-something.patch

< snip>

> * mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
> * mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks-fix.patch


Above two patch should be dropped. It has a bug.
Ref: https://lkml.org/lkml/2012/6/13/529

I sent bug fix patch.
1. https://lkml.org/lkml/2012/6/13/568

And then, clean up patch.
2. https://lkml.org/lkml/2012/6/13/570

Bartlomiej rebased his patch on above two patches.

3. https://lkml.org/lkml/2012/6/14/361

I hope I am not too late.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
