Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C12FC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C49EF20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:01:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DqSizuz1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C49EF20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DEB36B0007; Mon,  8 Apr 2019 16:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B44C6B0008; Mon,  8 Apr 2019 16:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357236B000A; Mon,  8 Apr 2019 16:01:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBF6D6B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 16:01:05 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j184so10885845pgd.7
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 13:01:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=xVh0abGIk/CaXpks5JMNE1h7dPbyclFz8hd/2iNFqZI=;
        b=KZreyiYSY+MQ/4uOXNuZUefTcTC61r70rm+Shc9706sT0JTyRmLOt1/OCY4Cwhq/gV
         6RHgeRTLSncO7isPcX1cfPz5OfZ+n478sFh4Qah93WaNr6JYLguWQ4Cat8VodyTwcLZy
         SnZiVuk1yBNBMMcqyiEfNWKicaSw2oG+0+SoeGJXoMhiL0/HasQ2B14pRWibamfatp9G
         oZ2V6HkARChw+3xdbfIHSGjwPQKc56vdRIYJvsQsASfnMswM8qOQGiyI3+C1Ou98s6fB
         gRJPNeyP3XXRVmGH0cHYcEZBZ5tGt3ySL+k4gRSBgG50E+nLcG1pHJsyINL5eJfzlPdE
         82cg==
X-Gm-Message-State: APjAAAWM5cR+Ibud1KpsRWMndN7JGr/EjzFjTLylhPWO+LueC8RrPJV1
	THcbvhahgg1rnqh/GvvTn0c49nwGWREUBt18gcFjKp2ICS/jZ80+uwBW183Q7H+qkssM47x25h0
	RQN0OJjf43PmvBS0yUb4Q903NbJyWvGe9wICdSTzMkACS0P+nMalCgjLc9/ReUE175g==
X-Received: by 2002:a65:5003:: with SMTP id f3mr30541517pgo.29.1554753665462;
        Mon, 08 Apr 2019 13:01:05 -0700 (PDT)
X-Received: by 2002:a65:5003:: with SMTP id f3mr30541416pgo.29.1554753664414;
        Mon, 08 Apr 2019 13:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554753664; cv=none;
        d=google.com; s=arc-20160816;
        b=OsQmqku5hddqnK/bDcJr3o4Q2GbkPFVI3E8+6pDvH8S4QJoeVgZBaU7oShFwtp9VoX
         6WEvBSPap7w1vgVz05Jw/0U/h8/1SoWwcmKp759EOfzCAsjUxqngcp4qf3a6gLJKMXT+
         0DJR6+xhSasnsWGjK4gLlFn+GfF8UBlVp1aJesnhpgh7dAdmwrBJfAjLMeNoAx/Hfvxe
         7oI6EMMuJIDxiVKMBrHBaxL2tFkUafbxpW7Q7pNQ0wxlE6yK615vw5lBatYlrf38fNyU
         H0yhDwQm3XFXSHNzfbUpLpI6G/yqG49ExKhKFCTtJrZoJFc1l4QMCr3SUpmtCrRUEe8+
         bKjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=xVh0abGIk/CaXpks5JMNE1h7dPbyclFz8hd/2iNFqZI=;
        b=TRc0Kx3Yl0CCNsS9Ahi9YWB1QX1DMo+42oLDze5XJ+LTd8lPfsuyp9LXubwYJVJOrh
         9UTqkIPU5fGeozDVyP8zZdWTcF/QrdHfZO9aW6AHYmqMPRirZQXFtG8Aihpz3uQeTQZS
         +p0W31L4AllWC6+QQRJyaTjs88eNlVU71hfxN76edmX3smMXejp06T9Z/OUPlWSLiUNy
         pFQVcbfKbO0NbivyLMqG9qg1iEy35kGnXFqFpg9buwk/wd9tLLANYV40KOPeq/c7Gglt
         zbLZpeEZzJxXINBNShyv9rGc5Y0VpW2Z+5Awv8fHwIWFTjwESti+Ny41CILPEZsZRXi0
         0jwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DqSizuz1;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24sor30912333pfn.22.2019.04.08.13.01.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 13:01:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DqSizuz1;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=xVh0abGIk/CaXpks5JMNE1h7dPbyclFz8hd/2iNFqZI=;
        b=DqSizuz1cjGbUl2f26QC9KngTLatAZfM/se0JI0BjNqjgur9mq4Nx84E9ZkjbzdxN/
         4O94IL3JOzNAf7rfNuN53wPw9laVx2mpMMCE3PMHQse8USTHUaZeGSaLAlJDyQZ2fwMO
         6FuFauc5u7Cp56G7GcAj4ADlAxEz6E3DFH9oAHp2A0AvCZW6Iso9VaudXWY4aLeH3Z9F
         Sy4jm6Lny8DzfBp236OLgXcWw7+e1mNYbkot5LktWIt5/bFsoDs46XVvXQbefHsdqB93
         maFy6MEpS3tfBXsjM+H4L1nLVGJo0CXuPfxhWe+i1vy9Pk6R2Y8TqmW9y052dRAlS9pO
         VgWw==
X-Google-Smtp-Source: APXvYqzu7cQVsvXaE3SZpOUeFoUHm3+r3PKIuTBGROvfIPGhokfKI5/K2klTZVQ/lfq32h9BYMURgw==
X-Received: by 2002:a62:2046:: with SMTP id g67mr31481444pfg.121.1554753663028;
        Mon, 08 Apr 2019 13:01:03 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id d187sm35843164pgc.43.2019.04.08.13.01.01
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 13:01:01 -0700 (PDT)
Date: Mon, 8 Apr 2019 13:01:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH 4/4] mm: swapoff: shmem_unuse() stop eviction without
 igrab()
In-Reply-To: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904081259400.1523@eggly.anvils>
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The igrab() in shmem_unuse() looks good, but we forgot that it gives no
protection against concurrent unmounting: a point made by Konstantin
Khlebnikov eight years ago, and then fixed in 2.6.39 by 778dd893ae78
("tmpfs: fix race between umount and swapoff"). The current 5.1-rc
swapoff is liable to hit "VFS: Busy inodes after unmount of tmpfs.
Self-destruct in 5 seconds.  Have a nice day..." followed by GPF.

Once again, give up on using igrab(); but don't go back to making such
heavy-handed use of shmem_swaplist_mutex as last time: that would spoil
the new design, and I expect could deadlock inside shmem_swapin_page().

Instead, shmem_unuse() just raise a "stop_eviction" count in the shmem-
specific inode, and shmem_evict_inode() wait for that to go down to 0.
Call it "stop_eviction" rather than "swapoff_busy" because it can be
put to use for others later (huge tmpfs patches expect to use it).

That simplifies shmem_unuse(), protecting it from both unlink and unmount;
and in practice lets it locate all the swap in its first try.  But do not
rely on that: there's still a theoretical case, when shmem_writepage()
might have been preempted after its get_swap_page(), before making the
swap entry visible to swapoff.

Fixes: b56a2d8af914 ("mm: rid swapoff of quadratic complexity")
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/shmem_fs.h |    1 +
 mm/shmem.c               |   39 ++++++++++++++++++---------------------
 mm/swapfile.c            |   11 +++++------
 3 files changed, 24 insertions(+), 27 deletions(-)

--- 5.1-rc4/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
+++ linux/include/linux/shmem_fs.h	2019-04-07 19:18:43.248639711 -0700
@@ -21,6 +21,7 @@ struct shmem_inode_info {
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
+	atomic_t		stop_eviction;	/* hold when working on inode */
 	struct inode		vfs_inode;
 };
 
--- 5.1-rc4/mm/shmem.c	2019-04-07 19:12:23.603858531 -0700
+++ linux/mm/shmem.c	2019-04-07 19:18:43.248639711 -0700
@@ -1081,9 +1081,15 @@ static void shmem_evict_inode(struct ino
 			}
 			spin_unlock(&sbinfo->shrinklist_lock);
 		}
-		if (!list_empty(&info->swaplist)) {
+		while (!list_empty(&info->swaplist)) {
+			/* Wait while shmem_unuse() is scanning this inode... */
+			wait_var_event(&info->stop_eviction,
+				       !atomic_read(&info->stop_eviction));
 			mutex_lock(&shmem_swaplist_mutex);
 			list_del_init(&info->swaplist);
+			/* ...but beware of the race if we peeked too early */
+			if (!atomic_read(&info->stop_eviction))
+				list_del_init(&info->swaplist);
 			mutex_unlock(&shmem_swaplist_mutex);
 		}
 	}
@@ -1227,36 +1233,27 @@ int shmem_unuse(unsigned int type, bool
 		unsigned long *fs_pages_to_unuse)
 {
 	struct shmem_inode_info *info, *next;
-	struct inode *inode;
-	struct inode *prev_inode = NULL;
 	int error = 0;
 
 	if (list_empty(&shmem_swaplist))
 		return 0;
 
 	mutex_lock(&shmem_swaplist_mutex);
-
-	/*
-	 * The extra refcount on the inode is necessary to safely dereference
-	 * p->next after re-acquiring the lock. New shmem inodes with swap
-	 * get added to the end of the list and we will scan them all.
-	 */
 	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
 		if (!info->swapped) {
 			list_del_init(&info->swaplist);
 			continue;
 		}
-
-		inode = igrab(&info->vfs_inode);
-		if (!inode)
-			continue;
-
+		/*
+		 * Drop the swaplist mutex while searching the inode for swap;
+		 * but before doing so, make sure shmem_evict_inode() will not
+		 * remove placeholder inode from swaplist, nor let it be freed
+		 * (igrab() would protect from unlink, but not from unmount).
+		 */
+		atomic_inc(&info->stop_eviction);
 		mutex_unlock(&shmem_swaplist_mutex);
-		if (prev_inode)
-			iput(prev_inode);
-		prev_inode = inode;
 
-		error = shmem_unuse_inode(inode, type, frontswap,
+		error = shmem_unuse_inode(&info->vfs_inode, type, frontswap,
 					  fs_pages_to_unuse);
 		cond_resched();
 
@@ -1264,14 +1261,13 @@ int shmem_unuse(unsigned int type, bool
 		next = list_next_entry(info, swaplist);
 		if (!info->swapped)
 			list_del_init(&info->swaplist);
+		if (atomic_dec_and_test(&info->stop_eviction))
+			wake_up_var(&info->stop_eviction);
 		if (error)
 			break;
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (prev_inode)
-		iput(prev_inode);
-
 	return error;
 }
 
@@ -2238,6 +2234,7 @@ static struct inode *shmem_get_inode(str
 		info = SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
+		atomic_set(&info->stop_eviction, 0);
 		info->seals = F_SEAL_SEAL;
 		info->flags = flags & VM_NORESERVE;
 		INIT_LIST_HEAD(&info->shrinklist);
--- 5.1-rc4/mm/swapfile.c	2019-04-07 19:17:13.291957539 -0700
+++ linux/mm/swapfile.c	2019-04-07 19:18:43.248639711 -0700
@@ -2116,12 +2116,11 @@ retry:
 	 * Under global memory pressure, swap entries can be reinserted back
 	 * into process space after the mmlist loop above passes over them.
 	 *
-	 * Limit the number of retries? No: when shmem_unuse()'s igrab() fails,
-	 * a shmem inode using swap is being evicted; and when mmget_not_zero()
-	 * above fails, that mm is likely to be freeing swap from exit_mmap().
-	 * Both proceed at their own independent pace: we could move them to
-	 * separate lists, and wait for those lists to be emptied; but it's
-	 * easier and more robust (though cpu-intensive) just to keep retrying.
+	 * Limit the number of retries? No: when mmget_not_zero() above fails,
+	 * that mm is likely to be freeing swap from exit_mmap(), which proceeds
+	 * at its own independent pace; and even shmem_writepage() could have
+	 * been preempted after get_swap_page(), temporarily hiding that swap.
+	 * It's easy and robust (though cpu-intensive) just to keep retrying.
 	 */
 	if (si->inuse_pages) {
 		if (!signal_pending(current))

