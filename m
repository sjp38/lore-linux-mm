Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2620B5F0001
	for <linux-mm@kvack.org>; Thu,  9 Apr 2009 06:06:36 -0400 (EDT)
Message-ID: <49DDC8AC.8090300@fastmail.fm>
Date: Thu, 09 Apr 2009 11:06:36 +0100
From: Jack Stone <jwjstone@fastmail.fm>
MIME-Version: 1.0
Subject: Re: [PATCH 25/56] mm: Remove void casts
References: <> <1239189748-11703-11-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-12-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-13-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-14-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-15-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-16-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-17-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-18-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-19-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-20-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-21-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-22-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-23-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-24-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-25-git-send-email-jwjstone@fastmail.fm> <1239189748-11703-26-git-send-email-jwjstone@fastmail.fm>
In-Reply-To: <1239189748-11703-26-git-send-email-jwjstone@fastmail.fm>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: jeff@garzik.org, kernel-janitors@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Added maintainer CC]
Jack Stone wrote:
> Remove uneeded void casts
>
> Signed-Off-By: Jack Stone <jwjstone@fastmail.fm>
> ---
>  mm/shmem.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d94d2e9..4febea9 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2357,7 +2357,7 @@ static struct kmem_cache *shmem_inode_cachep;
>  static struct inode *shmem_alloc_inode(struct super_block *sb)
>  {
>  	struct shmem_inode_info *p;
> -	p = (struct shmem_inode_info *)kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
> +	p = kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
>  	if (!p)
>  		return NULL;
>  	return &p->vfs_inode;
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
