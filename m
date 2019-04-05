Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C93A8C10F0F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 02:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53C77206DF
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 02:13:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Bs+T9Ol3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53C77206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 870EF6B000C; Thu,  4 Apr 2019 22:13:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821896B000D; Thu,  4 Apr 2019 22:13:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70FC06B000E; Thu,  4 Apr 2019 22:13:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3726F6B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 22:13:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e12so2878860pgh.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 19:13:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=tUroacfwrBy6lL79zmH8551Qv1VkDfzhsfmGX+L9dAo=;
        b=ahWCvoihUGbuok+7x4tBFUZBKSg0rHlpAfVPz9pzdKgMklFHy9tcF6zcmPFEmetPHY
         dP/XKK1h9E90G0IkFXm41U03EdfR3mgT45rfmKY+9bPDGkqVNxyMss1WNN/8qkZqdYDG
         hJgw9lYxntbeod9Arb5/8BjyRZUeESo3GXa2w7Vhn77IqXcUzKnipOVkRHvqxRmvrB7g
         rU55hTCgQNtkiGTGykujtgqaxo63hlGxeezQnvqin1SrtiYVTdBZd075iSEARtVgG1dB
         ynLtH2sj511ejDgCyG9W2YNozvesSwFi9A4VBhFHqkPe7q/R8tiDX/d5lkRc7IHZWsl5
         bNJA==
X-Gm-Message-State: APjAAAU+/VzhpkvcrjYYJUQTR9TtbChy2mSaO2KSE00aHCTgbLAnblAr
	yablxlrIm7FyKCFOvsm8YzkVsujuFetIYhA46tN7SkFLZmdwaQ/rrUe+b06TAX8kqcGrcVclPKQ
	Cp2LE1bynriQwrsHXUlaoLks4rKq7AY4O/ERWFC5Nll6+aY3hcLwC9JeWcf/qpkmt9g==
X-Received: by 2002:a17:902:e393:: with SMTP id ch19mr9629383plb.117.1554430399467;
        Thu, 04 Apr 2019 19:13:19 -0700 (PDT)
X-Received: by 2002:a17:902:e393:: with SMTP id ch19mr9629290plb.117.1554430398032;
        Thu, 04 Apr 2019 19:13:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554430398; cv=none;
        d=google.com; s=arc-20160816;
        b=zh9QYMGUSzBpQoBGixLMyYxRqWQs1ThhtkdbfznfgLr26B0zp0ysvk2GR7ZRNmSjWJ
         f4OU5AO4fsHmCPNGACei9a/RBlln4K7W/vZZsKuRkAxA23jlg3S0pFglTcHJJiIWsSy2
         sQPKNcxtK3+wrFn1OOeaHIIPhr1+Ld07rOnCKCyBtojAK4Vk684QrIW5r4sH+cBgQAh7
         BvYBAH3frceuBuY5+S9x4AEhRtYhaKYZJuRovCQcH9keGwpKoEfL/e3iJTqD6NT0YGNC
         pIvJiHSZ4ZpDRELkQZC+a9ujQaUvXyFQtOVTaSRVj5kdGJqFBlsqIOop5t9O+Dou6uOs
         J0ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=tUroacfwrBy6lL79zmH8551Qv1VkDfzhsfmGX+L9dAo=;
        b=ZbvWRJXuah9VWJzakbv2K5FxV4Q8/ctNoLxUQkfuVoE7RrdYZZ+19CTYJxn/cW6gw8
         174bSOYWC0/3yRQgTp3pw24lPLzBn3CVYnqgxmEv7i68Zo9u7xSMP3EH1FOJgl6v76Ai
         CYUdaPMHM9xonbax3F7Dc3EzYky6P/0yvIJxynev5GRY+mrLPzm/7yl2xCqPRANI/47s
         VIpliKdudGvR8MMpLJV9oicmEHf/hELrk3YP0dJtWCsVUyRwf5a4r5I0PtbWyBtzgGjW
         8pb0k6DS93yYRjA2j9zYF6UiF2hw+IHnNGRTTIAL2yHUGcDrztRDuG/HdOgZmEzkuDYw
         rDpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Bs+T9Ol3;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor23085720pgj.8.2019.04.04.19.13.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 19:13:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Bs+T9Ol3;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=tUroacfwrBy6lL79zmH8551Qv1VkDfzhsfmGX+L9dAo=;
        b=Bs+T9Ol3DQGDKYCuicytmPBqHhdII/4R3EaLGvvW/GmXSy5wx78PDXcgFHVSGz1kpX
         bNcsUZpGiDi5RGuJn8ByksYLXGzyUnb3efYD8HGcVkkXsrWVgInUUotHOjXhbFlH/L3P
         fb1YcxmTHPRcdePHqlmHubpwJGJyrgy+rrBiJ5iWvmlb1mKo/Rq8LaL9+3B3nWYj1jsg
         GIlHROOS8mCUiubHPIPVZmjWIStFIxNEwboY39RqdiaILqSI3aXfigSk0nLUdZLFa78e
         VkSc4iiBZ7ZBsyWI+7tZy/jnjf2/mnDTYT9yB8BwqnPKwzIf9+5mpLy+Ot74C4sI4Xwt
         vkBg==
X-Google-Smtp-Source: APXvYqxjspHKjopAF5J/tOC/wVEYc936hfd0FD459ovmUjNa/rlVRZiePd29QwMWPCjBTR9GEhn4QA==
X-Received: by 2002:a63:e44f:: with SMTP id i15mr5817090pgk.362.1554430396418;
        Thu, 04 Apr 2019 19:13:16 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id r8sm26863782pfd.8.2019.04.04.19.13.14
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 19:13:15 -0700 (PDT)
Date: Thu, 4 Apr 2019 19:12:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
cc: Hugh Dickins <hughd@google.com>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer
 dereference
In-Reply-To: <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1904041836030.25100@eggly.anvils>
References: <1553440122.7s759munpm.astroid@alex-desktop.none> <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com> <1554048843.jjmwlalntd.astroid@alex-desktop.none> <alpine.LSU.2.11.1903311146040.2667@eggly.anvils>
 <alpine.LSU.2.11.1904021701270.5045@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Apr 2019, Hugh Dickins wrote:
> On Sun, 31 Mar 2019, Hugh Dickins wrote:
> > On Sun, 31 Mar 2019, Alex Xu (Hello71) wrote:
> > > Excerpts from Vineeth Pillai's message of March 25, 2019 6:08 pm:
> > > > On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
> > > >>
> > > >> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
> > > >> suspect my setup erroneously executes two swapoff+cryptsetup close
> > > >> operations simultaneously, so a race condition is triggered.
> > > >>
> > > >> I am using a single swap on a plain dm-crypt device on a MBR partition
> > > >> on a SATA drive.
> > > >>
> > > >> I think the problem is probably related to
> > > >> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
> > > >>
> > > > Could you please provide more information on this - stack trace, dmesg etc?
> > > > Is it easily reproducible? If yes, please detail the steps so that I
> > > > can try it inhouse.
> > > > 
> > > > Thanks,
> > > > Vineeth
> > > > 
> > > 
> > > Some info from the BUG entry (I didn't bother to type it all, 
> > > low-quality image available upon request):
> > > 
> > > BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> > > #PF error: [normal kernel read fault]
> > > PGD 0 P4D 0
> > > Oops: 0000 [#1] SMP
> > > CPU: 0 Comm: swapoff Not tainted 5.1.0-rc1+ #2
> > > RIP: 0010:shmem_recalc_inode+0x41/0x90
> > > 
> > > Call Trace:
> > > ? shmem_undo_range
> > > ? rb_erase_cached
> > > ? set_next_entity
> > > ? __inode_wait_for_writeback
> > > ? shmem_truncate_range
> > > ? shmem_evict_inode
> > > ? evict
> > > ? shmem_unuse
> > > ? try_to_unuse
> > > ? swapcache_free_entries
> > > ? _cond_resched
> > > ? __se_sys_swapoff
> > > ? do_syscall_64
> > > ? entry_SYSCALL_64_after_hwframe
> > > 
> > > As I said, it only occurs occasionally on shutdown. I think it is a safe 
> > > guess that it can only occur when the swap is not empty, but possibly 
> > > other conditions are necessary, so I will test further.
> > 
> > Thanks for the update, Alex. I'm looking into a couple of bugs with the
> > 5.1-rc swapoff, but this one doesn't look like anything I know so far.
> > shmem_recalc_inode() is a surprising place to crash: it's as if the
> > igrab() in shmem_unuse() were not working. 
> > 
> > Yes, please do send Vineeth and me (or the lists) your low-quality image,
> > in case we can extract any more info from it; and also please the
> > disassembly of your kernel's shmem_recalc_inode(), so we can be sure of
> > exactly what it's crashing on (though I expect that will leave me as
> > puzzled as before).
> > 
> > If you want to experiment with one of my fixes, not yet written up and
> > posted, just try changing SWAP_UNUSE_MAX_TRIES in mm/swapfile.c from
> > 3 to INT_MAX: I don't see how that issue could manifest as crashing in
> > shmem_recalc_inode(), but I may just be too stupid to see it.
> 
> Thanks for the image and disassembly you sent: which showed that the
> ffffffff81117351:       48 83 3f 00             cmpq   $0x0,(%rdi)
> you are crashing on, is the "if (sbinfo->max_blocks)" in the inlined
> shmem_inode_unacct_blocks(): inode->i_sb->s_fs_info is NULL, which is
> something that shmem_put_super() does.
> 
> Eight-year-old memories stirred: I knew when looking at Vineeth's patch,
> that I ought to look back through the history of mm/shmem.c, to check
> some points that Konstantin Khlebnikov had made years ago, that
> surprised me then and were in danger of surprising us again with this
> rework. But I failed to do so: thank you Alex, for reporting this bug
> and pointing us back there.
> 
> igrab() protects from eviction but does not protect from unmounting.
> I bet that is what you are hitting, though I've not even read through
> 2.6.39's 778dd893ae785 ("tmpfs: fix race between umount and swapoff")
> again yet, and not begun to think of the fix for it this time around;
> but wanted to let you know that this bug is now (probably) identified.

Hi Alex, could you please give the patch below a try? It fixes a
problem, but I'm not sure that it's your problem - please let us know.

I've not yet written up the commit description, and this should end up
as 4/4 in a series fixing several new swapoff issues: I'll wait to post
the finished series until heard back from you.

I did first try following the suggestion Konstantin had made back then,
for a similar shmem_writepage() case: atomic_inc_not_zero(&sb->s_active).

But it turned out to be difficult to get right in shmem_unuse(), because
of the way that relies on the inode as a cursor in the list - problem
when you've acquired an s_active reference, but fail to acquire inode
reference, and cannot safely release the s_active reference while still
holding the swaplist mutex.

If VFS offered an isgrab(inode), like igrab() but acquiring s_active
reference while holding i_lock, that would drop very easily into the
current shmem_unuse() as a replacement there for igrab(). But the rest
of the world has managed without that for years, so I'm disinclined to
add it just for this. And the patch below seems good enough without it.

Thanks,
Hugh

---

 include/linux/shmem_fs.h |    1 +
 mm/shmem.c               |   39 ++++++++++++++++++---------------------
 2 files changed, 19 insertions(+), 21 deletions(-)

--- 5.1-rc3/include/linux/shmem_fs.h	2019-03-17 16:18:15.181820820 -0700
+++ linux/include/linux/shmem_fs.h	2019-04-04 16:18:08.193512968 -0700
@@ -21,6 +21,7 @@ struct shmem_inode_info {
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
 	struct simple_xattrs	xattrs;		/* list of xattrs */
+	atomic_t		stop_eviction;	/* hold when working on inode */
 	struct inode		vfs_inode;
 };
 
--- 5.1-rc3/mm/shmem.c	2019-03-17 16:18:15.701823872 -0700
+++ linux/mm/shmem.c	2019-04-04 16:18:08.193512968 -0700
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

