Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 416DF6B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:30:34 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id c1so93925igq.0
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:30:34 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id d6si5818976igg.44.2014.06.25.15.30.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 15:30:33 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so19061igb.5
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:30:33 -0700 (PDT)
Date: Wed, 25 Jun 2014 15:30:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: update the description for madvise_remove
In-Reply-To: <53AA2CD5.6060202@gmail.com>
Message-ID: <alpine.DEB.2.02.1406251529530.4592@chino.kir.corp.google.com>
References: <53A9116B.9030004@gmail.com> <alpine.DEB.2.02.1406241542040.29176@chino.kir.corp.google.com> <53AA2CD5.6060202@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <ak@linux.intel.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-man@vger.kernel.org

On Wed, 25 Jun 2014, Wang Sheng-Hui wrote:

> Patch to man-page.
> 
> [PATCH] madvise.2: update the description for MADV_REMOVE
> 
> Currently we have more filesystems supporting fallcate, e.g ext4/btrfs,
> which can response to MADV_REMOVE gracefully.
> 
> And if filesystems don't support fallocate, the return error would be
> EOPNOTSUPP, instead of ENOSYS.
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Great, thanks!  This looks like it can be applied immediately and doesn't 
require us to wait for any kernel change.

Good catch with the return value.

> ---
>  man2/madvise.2 | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index 032ead7..4ce869c 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -99,13 +99,9 @@ or zero-fill-on-demand pages for mappings
>  without an underlying file.
>  .TP
>  .BR MADV_REMOVE " (since Linux 2.6.16)"
> -Free up a given range of pages
> -and its associated backing store.
> -Currently,
> -.\" 2.6.18-rc5
> -only shmfs/tmpfs supports this; other filesystems return with the
> -error
> -.BR ENOSYS .
> +Free up a given range of pages and its associated backing store.
> +Filesystems that don't support fallocate will return error
> +.BR EOPNOTSUPP.
>  .\" Databases want to use this feature to drop a section of their
>  .\" bufferpool (shared memory segments) - without writing back to
>  .\" disk/swap space.  This feature is also useful for supporting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
