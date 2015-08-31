Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1720B6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 18:54:26 -0400 (EDT)
Received: by igui7 with SMTP id i7so66621778igu.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:54:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y22si5983254ioi.38.2015.08.31.15.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 15:54:25 -0700 (PDT)
Date: Mon, 31 Aug 2015 15:54:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg: always enable kmemcg on the default
 hierarchy
Message-Id: <20150831155423.41fd128501c0e75ab1981a65@linux-foundation.org>
In-Reply-To: <20150828220237.GE11089@htj.dyndns.org>
References: <20150828220158.GD11089@htj.dyndns.org>
	<20150828220237.GE11089@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri, 28 Aug 2015 18:02:37 -0400 Tejun Heo <tj@kernel.org> wrote:

> On the default hierarchy, all memory consumption will be accounted
> together and controlled by the same set of limits.  Enable kmemcg on
> the default hierarchy by default.  Boot parameter "disable_kmemcg" can
> be specified to turn it off.
> 
> ...
>
>  mm/memcontrol.c |   43 ++++++++++++++++++++++++++++++-------------
>  1 file changed, 30 insertions(+), 13 deletions(-)

Some documentation updates will be needed?
 
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -346,6 +346,17 @@ EXPORT_SYMBOL(tcp_proto_cgroup);
>  #endif
>  
>  #ifdef CONFIG_MEMCG_KMEM
> +
> +static bool kmemcg_disabled;
> +
> +static int __init disable_kmemcg(char *s)
> +{
> +	kmemcg_disabled = true;
> +	pr_info("memcg: kernel memory support disabled on cgroup2");

typo?

> +	return 0;
> +}
> +__setup("disable_kmemcg", disable_kmemcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
