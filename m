Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id D3EB46B007D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 11:07:01 -0400 (EDT)
Date: Thu, 27 Sep 2012 15:07:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] sl[au]b: process slabinfo_show in common code
In-Reply-To: <1348756660-16929-5-git-send-email-glommer@parallels.com>
Message-ID: <0000013a08443b02-5715bfe6-9c47-49c5-a951-8a48cc432e42-000000@email.amazonses.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com> <1348756660-16929-5-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -239,7 +239,23 @@ static void s_stop(struct seq_file *m, void *p)
>
>  static int s_show(struct seq_file *m, void *p)
>  {
> -	return slabinfo_show(m, p);
> +	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
> +	struct slabinfo sinfo;
> +
> +	memset(&sinfo, 0, sizeof(sinfo));
> +	get_slabinfo(s, &sinfo);

Could get_slabinfo() also set the objects per slab etc in some additional
field in struct slabinfo? Then we can avoid the exporting of the oo_
functions and we do not need the cache_order() etc functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
