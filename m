Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8EFF6B026D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:57:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 17-v6so8161061qkz.15
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:57:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o64-v6si3235547qte.153.2018.07.11.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 07:57:26 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <153131984019.24777.15284245961241666054.stgit@localhost.localdomain>
References: <153131984019.24777.15284245961241666054.stgit@localhost.localdomain>
Subject: Re: [PATCH] fs: Fix double prealloc_shrinker() in sget_fc()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <24666.1531321044.1@warthog.procyon.org.uk>
Date: Wed, 11 Jul 2018 15:57:24 +0100
Message-ID: <24667.1531321044@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> diff --git a/fs/super.c b/fs/super.c
> index 13647d4fd262..47a819f1a300 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -551,7 +551,7 @@ struct super_block *sget_fc(struct fs_context *fc,
>  	hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
>  	spin_unlock(&sb_lock);
>  	get_filesystem(s->s_type);
> -	register_shrinker(&s->s_shrink);
> +	register_shrinker_prepared(&s->shrinker);
>  	return s;
>  }
>  EXPORT_SYMBOL(sget_fc);
> 

I already folded in a fix from Eric for this, but Al hasn't pulled the updated
tree yet.

David
