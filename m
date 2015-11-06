Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2B31282F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 22:52:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so84109116pac.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 19:52:21 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-250.mail.alibaba.com. [205.204.113.250])
        by mx.google.com with ESMTP id co2si14611387pbb.197.2015.11.05.19.52.19
        for <linux-mm@kvack.org>;
        Thu, 05 Nov 2015 19:52:21 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [patch] mm, oom: add comment for why oom_adj exists
Date: Fri, 06 Nov 2015 11:52:01 +0800
Message-ID: <009801d11846$7eb2f610$7c18e230$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hongjie.Fang@spreadtrum.com, "'Eric W. Biederman'" <ebiederm@xmission.com>

> 
> /proc/pid/oom_adj exists solely to avoid breaking existing userspace
> binaries that write to the tunable.
> 
> Add a comment in the only possible location within the kernel tree to
> describe the situation and motivation for keeping it around.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  fs/proc/base.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1032,6 +1032,16 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
>  	return simple_read_from_buffer(buf, count, ppos, buffer, len);
>  }
> 
> +/*
> + * /proc/pid/oom_adj exists solely for backwards compatibility with previous
> + * kernels.  The effective policy is defined by oom_score_adj, which has a
> + * different scale: oom_adj grew exponentially and oom_score_adj grows linearly.
> + * Values written to oom_adj are simply mapped linearly to oom_score_adj.
> + * Processes that become oom disabled via oom_adj will still be oom disabled
> + * with this implementation.
> + *
> + * oom_adj cannot be removed since existing userspace binaries use it.
> + */
>  static ssize_t oom_adj_write(struct file *file, const char __user *buf,
>  			     size_t count, loff_t *ppos)
>  {
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
