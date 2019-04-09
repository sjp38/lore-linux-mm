Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F21BAC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:50:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C99820857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:50:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="juY+UUbV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C99820857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF30F6B026A; Tue,  9 Apr 2019 03:50:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9FE26B026B; Tue,  9 Apr 2019 03:50:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A42636B026C; Tue,  9 Apr 2019 03:50:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 383E56B026A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:50:50 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v67so4548185lje.15
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:50:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5n9WEogrExMzk0KIwWXK93X0lG5/IG5LFZM0tYqqIxw=;
        b=TLjiA1Wv3whAId7gVHCKx2bWpDI32JWmEWaVzRjz8WC0Mjn30bRpFt3vCccKcI2lUM
         SVd6L/c4KqsVcvw6r8RlOohOAKC274D2y5t3cZlz5lgF1XiUH8wDQXy6ODB4pWkZoz8R
         QPbQfDUM+AySFZEnwEtah1SLFz70fDqRK4/PipGL2T3yPxh6kf/4vbjSZcGs/9KkLJmg
         bbJhQxeOcxqcr4ojxhyW74tz2gMiNiwu1z3FZolorgn3BazLkXZ6SqlPb9D37ZUMYCwn
         P7kjn5PwSdFfZcED3rdsn0pwmdeT+lzcmrFA7gp5a4AD0o9kkHKuEagYQg3oMvYz4OWo
         SNRw==
X-Gm-Message-State: APjAAAU8rEkHnKLvTrolRN8W9RkRdjrI4xmaoYSR8J6I9OkbucNE53/1
	WElpZuD6xOBCCgqd6/b8dbc1ecSENz+CyVOAI6MPpOLm0GvUVWtQvES3+nHzE7TnvLjE3oEezU3
	q3QdUrV2rx9sHC6N7AQ7aGe7NmCkCt6mEfCjIS4nLH8rfvKZcW5KUrBm9aetvChheuA==
X-Received: by 2002:a2e:9842:: with SMTP id e2mr18691309ljj.142.1554796249207;
        Tue, 09 Apr 2019 00:50:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF3/ynmA0hYEdXZzJ+7JeCkWqIKenG6XZFlc+vhFSVNGxck7Kiu983rjaFHkW5pGk9HzI7
X-Received: by 2002:a2e:9842:: with SMTP id e2mr18691264ljj.142.1554796248197;
        Tue, 09 Apr 2019 00:50:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554796248; cv=none;
        d=google.com; s=arc-20160816;
        b=Cx5Akg6He/0lBBgXgC1Tj5aq7HcVR+odjS28AnaQbzLH5ixHAGV+8zyuUmDWdltd4X
         VvCog5tE/CP8Keu/TaIbh9EMCuC5l9omIzHDfzmauU9B9kMz9+XQpka21donrdHGz6u7
         FNqub9EGiOGGIZWYY0KOl5QOhq5DE2o/zOTnKdnLFfG2VY6KpPZIwWpb1xgjEGG5m/xg
         v3ZF/U16fptInfq3n/LxZhuEfYmsmaQTFOjV8hUUIODF4/uW/qPv0qj7EDdz3PZuuB2b
         uBYic6+m/LxpVv1VsmLm4vSvv9WCUaTmbCd6dhP3QUskIMr2eeKKKNcR0kp8wL2oKavx
         yfXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=5n9WEogrExMzk0KIwWXK93X0lG5/IG5LFZM0tYqqIxw=;
        b=QKv1vLzepffyLHkrogEx0ZhdJ3D65pL/5uEZEIiexjKUVDe8mSesb7dCQYZr0y7GuQ
         FxTh3lDgtH/wjLG4HhwoDsMOeA8ddHis088H0ec09OZmlM3BZbw9ieFTzeKs/OFK0aCA
         ibU0ncTv+mLPD9AdDpD64ZpnxXi8TUDnbL8ceKPUcY6+kof1ZSB1hK2XT/vA7kscdrf3
         sYAag0RUmO8U92lCNl6FChvUv37UlIM5KY5p8hgPnnJACzlUDQQBF4W9OLpUc0wy5Ftx
         Drc8eZmit/ghBU8o16c0a3KCotT41gBrxdMTLS27TD+S6jnlxhrii8W7YwNixohxWGYI
         k71A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=juY+UUbV;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id y14si22129032lfg.61.2019.04.09.00.50.47
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 00:50:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=juY+UUbV;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 5F0892E148A;
	Tue,  9 Apr 2019 10:50:47 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id B4TaDFTwR2-okeC816t;
	Tue, 09 Apr 2019 10:50:47 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554796247; bh=5n9WEogrExMzk0KIwWXK93X0lG5/IG5LFZM0tYqqIxw=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=juY+UUbVKo19dGQE3Ov9pALKcgKU/iV8uI6DT1z0Z3f/vnkLuBBLk9Jnr5QMztCfq
	 /pLkEGv5Zj+eUlTYzmriIH37wWI1hBTvywgqfyIv4mVpzkmBI+mHJmnvjItYvXpGH3
	 CkUXE/BCvD7w0FBHAkHwyQYFLNXmB2GhFPggbbAY=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f5ec:9361:ed45:768f])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id vw2fAYqwFN-okkKluUD;
	Tue, 09 Apr 2019 10:50:46 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 4/4] mm: swapoff: shmem_unuse() stop eviction without
 igrab()
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>,
 Vineeth Pillai <vpillai@digitalocean.com>,
 Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>,
 Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
 <alpine.LSU.2.11.1904081259400.1523@eggly.anvils>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <84d74937-30ed-d0fe-c7cd-a813f61cbb96@yandex-team.ru>
Date: Tue, 9 Apr 2019 10:50:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1904081259400.1523@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.2019 23:01, Hugh Dickins wrote:
> The igrab() in shmem_unuse() looks good, but we forgot that it gives no
> protection against concurrent unmounting: a point made by Konstantin
> Khlebnikov eight years ago, and then fixed in 2.6.39 by 778dd893ae78
> ("tmpfs: fix race between umount and swapoff"). The current 5.1-rc
> swapoff is liable to hit "VFS: Busy inodes after unmount of tmpfs.
> Self-destruct in 5 seconds.  Have a nice day..." followed by GPF.
> 
> Once again, give up on using igrab(); but don't go back to making such
> heavy-handed use of shmem_swaplist_mutex as last time: that would spoil
> the new design, and I expect could deadlock inside shmem_swapin_page().
> 
> Instead, shmem_unuse() just raise a "stop_eviction" count in the shmem-
> specific inode, and shmem_evict_inode() wait for that to go down to 0.
> Call it "stop_eviction" rather than "swapoff_busy" because it can be
> put to use for others later (huge tmpfs patches expect to use it).
> 
> That simplifies shmem_unuse(), protecting it from both unlink and unmount;
> and in practice lets it locate all the swap in its first try.  But do not
> rely on that: there's still a theoretical case, when shmem_writepage()
> might have been preempted after its get_swap_page(), before making the
> swap entry visible to swapoff.
> 
> Fixes: b56a2d8af914 ("mm: rid swapoff of quadratic complexity")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>   include/linux/shmem_fs.h |    1 +
>   mm/shmem.c               |   39 ++++++++++++++++++---------------------
>   mm/swapfile.c            |   11 +++++------
>   3 files changed, 24 insertions(+), 27 deletions(-)
> 
> --- 5.1-rc4/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
> +++ linux/include/linux/shmem_fs.h	2019-04-07 19:18:43.248639711 -0700
> @@ -21,6 +21,7 @@ struct shmem_inode_info {
>   	struct list_head	swaplist;	/* chain of maybes on swap */
>   	struct shared_policy	policy;		/* NUMA memory alloc policy */
>   	struct simple_xattrs	xattrs;		/* list of xattrs */
> +	atomic_t		stop_eviction;	/* hold when working on inode */
>   	struct inode		vfs_inode;
>   };
>   
> --- 5.1-rc4/mm/shmem.c	2019-04-07 19:12:23.603858531 -0700
> +++ linux/mm/shmem.c	2019-04-07 19:18:43.248639711 -0700
> @@ -1081,9 +1081,15 @@ static void shmem_evict_inode(struct ino
>   			}
>   			spin_unlock(&sbinfo->shrinklist_lock);
>   		}
> -		if (!list_empty(&info->swaplist)) {
> +		while (!list_empty(&info->swaplist)) {
> +			/* Wait while shmem_unuse() is scanning this inode... */
> +			wait_var_event(&info->stop_eviction,
> +				       !atomic_read(&info->stop_eviction));
>   			mutex_lock(&shmem_swaplist_mutex);

>   			list_del_init(&info->swaplist);

Obviously, line above should be deleted.

> +			/* ...but beware of the race if we peeked too early */
> +			if (!atomic_read(&info->stop_eviction))
> +				list_del_init(&info->swaplist);
>   			mutex_unlock(&shmem_swaplist_mutex);
>   		}
>   	}
> @@ -1227,36 +1233,27 @@ int shmem_unuse(unsigned int type, bool
>   		unsigned long *fs_pages_to_unuse)
>   {
>   	struct shmem_inode_info *info, *next;
> -	struct inode *inode;
> -	struct inode *prev_inode = NULL;
>   	int error = 0;
>   
>   	if (list_empty(&shmem_swaplist))
>   		return 0;
>   
>   	mutex_lock(&shmem_swaplist_mutex);
> -
> -	/*
> -	 * The extra refcount on the inode is necessary to safely dereference
> -	 * p->next after re-acquiring the lock. New shmem inodes with swap
> -	 * get added to the end of the list and we will scan them all.
> -	 */
>   	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
>   		if (!info->swapped) {
>   			list_del_init(&info->swaplist);
>   			continue;
>   		}
> -
> -		inode = igrab(&info->vfs_inode);
> -		if (!inode)
> -			continue;
> -
> +		/*
> +		 * Drop the swaplist mutex while searching the inode for swap;
> +		 * but before doing so, make sure shmem_evict_inode() will not
> +		 * remove placeholder inode from swaplist, nor let it be freed
> +		 * (igrab() would protect from unlink, but not from unmount).
> +		 */
> +		atomic_inc(&info->stop_eviction);
>   		mutex_unlock(&shmem_swaplist_mutex);
> -		if (prev_inode)
> -			iput(prev_inode);
> -		prev_inode = inode;
>   
> -		error = shmem_unuse_inode(inode, type, frontswap,
> +		error = shmem_unuse_inode(&info->vfs_inode, type, frontswap,
>   					  fs_pages_to_unuse);
>   		cond_resched();
>   
> @@ -1264,14 +1261,13 @@ int shmem_unuse(unsigned int type, bool
>   		next = list_next_entry(info, swaplist);
>   		if (!info->swapped)
>   			list_del_init(&info->swaplist);
> +		if (atomic_dec_and_test(&info->stop_eviction))
> +			wake_up_var(&info->stop_eviction);
>   		if (error)
>   			break;
>   	}
>   	mutex_unlock(&shmem_swaplist_mutex);
>   
> -	if (prev_inode)
> -		iput(prev_inode);
> -
>   	return error;
>   }
>   
> @@ -2238,6 +2234,7 @@ static struct inode *shmem_get_inode(str
>   		info = SHMEM_I(inode);
>   		memset(info, 0, (char *)inode - (char *)info);
>   		spin_lock_init(&info->lock);
> +		atomic_set(&info->stop_eviction, 0);
>   		info->seals = F_SEAL_SEAL;
>   		info->flags = flags & VM_NORESERVE;
>   		INIT_LIST_HEAD(&info->shrinklist);
> --- 5.1-rc4/mm/swapfile.c	2019-04-07 19:17:13.291957539 -0700
> +++ linux/mm/swapfile.c	2019-04-07 19:18:43.248639711 -0700
> @@ -2116,12 +2116,11 @@ retry:
>   	 * Under global memory pressure, swap entries can be reinserted back
>   	 * into process space after the mmlist loop above passes over them.
>   	 *
> -	 * Limit the number of retries? No: when shmem_unuse()'s igrab() fails,
> -	 * a shmem inode using swap is being evicted; and when mmget_not_zero()
> -	 * above fails, that mm is likely to be freeing swap from exit_mmap().
> -	 * Both proceed at their own independent pace: we could move them to
> -	 * separate lists, and wait for those lists to be emptied; but it's
> -	 * easier and more robust (though cpu-intensive) just to keep retrying.
> +	 * Limit the number of retries? No: when mmget_not_zero() above fails,
> +	 * that mm is likely to be freeing swap from exit_mmap(), which proceeds
> +	 * at its own independent pace; and even shmem_writepage() could have
> +	 * been preempted after get_swap_page(), temporarily hiding that swap.
> +	 * It's easy and robust (though cpu-intensive) just to keep retrying.
>   	 */
>   	if (si->inuse_pages) {
>   		if (!signal_pending(current))
> 

