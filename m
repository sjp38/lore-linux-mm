Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C3F9C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C08EA21920
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:04:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iTwuZODZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C08EA21920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 459F18E0002; Fri, 15 Feb 2019 03:04:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E03B8E0001; Fri, 15 Feb 2019 03:04:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 282A38E0002; Fri, 15 Feb 2019 03:04:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8C1F8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:04:24 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id q185so5415622ywf.8
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 00:04:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QuEfGz9b+yTPacvnfh/QMnf3j7UM3cHWmseR0aorNT0=;
        b=LCeMHQrinFZiLYUbSYmksJMn02lmzlVyisqVq4jjuQTnVo40vZszxIitLm+c1mQaU9
         taIcKVyYHz5ATGoqov+NaXmEhJutd3mnro+SXzfYpTpkZecDbn52r/ZKXLhTaqzpNWbc
         9JjRV3/nnT6rtup+e3ntcQCWU9yS36dPsL1YWgTDnFSEhEHX+iRPmPBeWzr6Iyc8TkMC
         OsiltiqQSb3h3MdhXm2igvjv3HT3Ome85sQF3n3+mxbytoHOVkphSgpQ8J1YD/3ILw55
         tzVULCd3BfU3NjAPX8Bon9apupg28oBlVALJIZxeexImmNHQJKzJX7Aw4dSopvczuVuR
         h68Q==
X-Gm-Message-State: AHQUAubR6iRmiDyQKXFDb3R62YmEhbwQ7xKcEvNu+bZ0U8SFkm4KhW+J
	60t+mGXT1RIGyHlQHaOSmAcx9zVc2gCe+a1Iq1fi1ZPD0HFUvjltTnrUUizd/urGWrFljONOyQU
	lclVfyv3ls8w4KIYmzpvnZ3tZpBZTmSjzAqIqo1eAeeEsEMNZiyIvf89WAH1yBmVX/lpKC3dtSO
	Y4Ckxa2CueHyXcGNhOY8I/m9cgPyLlW7YVgeImb7ISXM4X2TV1leF2pZfngMtSEXSfmrGTu5zHs
	S41VhB9pmeCNg7AFHmY7OW3um/b3Ff6S8PkKhudI+MTeRhRUQ88Jr9P08vhSpsBG3OYHkalSlr8
	LgQVxpnGkwIkABfQwNuLvCMFb4X7aaBEpQmYdILIee2uEzfuBosQDbWraui7ME4bIRnkV7dBTdk
	U
X-Received: by 2002:a81:e408:: with SMTP id r8mr6851410ywl.367.1550217864548;
        Fri, 15 Feb 2019 00:04:24 -0800 (PST)
X-Received: by 2002:a81:e408:: with SMTP id r8mr6851369ywl.367.1550217863854;
        Fri, 15 Feb 2019 00:04:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550217863; cv=none;
        d=google.com; s=arc-20160816;
        b=BmCysGuV6dlts/mfEkERgs60o+aFVR4F2G9ptdUKt91z8nv3pyMPkDn3KQ33eTi7LC
         L+2QdAko2jJ+AekoU0jZIcMJQky/k2LK3DXj3ClCm8C0wrwT79ZiHnLO9DryB6DwP6Nu
         xHk4pMA4fhkvTnkF3ABLgtSlNZr2op/qMrVCAS2itjsciszFQMXeyRmCzMpaygA1U6IQ
         Z8dd35t5oSXmbBPER/EZvAJWI/fsmWQPC7fVlRN4TgEAZsKRF9oIfUiMDlqORvB74jfr
         jJ1MfWQ84N7bwQnFmFbMoyE3wb4xwJal10WfoNWo1oKTYrhBpMCiBsRZC1+hEU6Q3gvk
         IlwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QuEfGz9b+yTPacvnfh/QMnf3j7UM3cHWmseR0aorNT0=;
        b=PUwYTfyGu9migvyRungBFNkmotSckWUV8tWaxTuaE565nR12vvmS+yBAWu7NvjZk//
         1nCw1NsfMm3Dg+YpGCEp22fqgSplxOqmBSWRuoLO1SuCSRlVEN2MIl06GmYmHZWkvdmq
         x7Eb60cAxB2RbotraPaKZuw336cj5pWefx6rvNTkQr5Bjj+wY2UvnsT0VH/Y77sxseGE
         mEv/8qvc+AWtIVcoL7vTSq2YJfaWo4s+HqcGueVr+l7k7tCpRhUd4nZS0+VVjyCJJG20
         vlCd5cSGKxCHByvViPWgNhTRNfBrgu3PaPxkObRsZpLa2kpBuHOLKNN2JgQSPyeI01oK
         1zCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iTwuZODZ;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k11sor2720326ybm.112.2019.02.15.00.04.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 00:04:23 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iTwuZODZ;
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QuEfGz9b+yTPacvnfh/QMnf3j7UM3cHWmseR0aorNT0=;
        b=iTwuZODZm/rOKVxYNUyD7WhyONkGHoFKvHJmU7KQQHd0OVhYrDsruvhfGPlzfQWG7d
         +LhdlRPH0b3tYOAMqbilffCBDMxU5eztxCZaPrJbLzNokDIQxUvUtbg86I0sLJtkPR7o
         VOrHSFY3YblvfYFJEYnLYjMCRkAXhEobe5kACtHAKixavdyqWYZacDFfwCgtB/N4/IcK
         zfNUci1q3fNIzEgFayI+DNU2j8H0pqP20H424oIRwjqC24gbo0ogGEtWdpawpXfjAj1w
         nxWq+N1u0WqkaL4TuPva8RtuFImC2B69xUzGCHeEUkPFdzi2hD5jVIOqCYp5KSBakC4G
         c+sw==
X-Google-Smtp-Source: AHgI3IbStHEFP2mPJIlWtmF4n/NoxAegtGV89PF4VxWaRToDnmSo0gKvywSNl1E5lM/gDGjkKC8HTPs6V3PZGp1+bd8=
X-Received: by 2002:a25:9c09:: with SMTP id c9mr7114969ybo.462.1550217863552;
 Fri, 15 Feb 2019 00:04:23 -0800 (PST)
MIME-Version: 1.0
References: <20190214234908.GA6474@magnolia>
In-Reply-To: <20190214234908.GA6474@magnolia>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 15 Feb 2019 10:04:12 +0200
Message-ID: <CAOQ4uxho2AK7g-uhHykGaG6n+aqad-SaCTC6Z_EaA4Jn07tDSg@mail.gmail.com>
Subject: Re: [PATCH] vfs: don't decrement i_nlink in d_tmpfile
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, dsterba@suse.com, 
	Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, Theodore Tso <tytso@mit.edu>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, yuchao0@huawei.com, 
	Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, 
	Richard Weinberger <richard@nod.at>, Artem Bityutskiy <dedekind1@gmail.com>, 
	Adrian Hunter <adrian.hunter@intel.com>, linux-xfs <linux-xfs@vger.kernel.org>, 
	Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Ext4 <linux-ext4@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, 
	linux-mtd@lists.infradead.org, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 4:23 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> d_tmpfile was introduced to instantiate an inode in the dentry cache as
> a temporary file.  This helper decrements the inode's nlink count and
> dirties the inode, presumably so that filesystems could call new_inode
> to create a new inode with nlink == 1 and then call d_tmpfile which will
> decrement nlink.
>
> However, this doesn't play well with XFS, which needs to allocate,
> initialize, and insert a tempfile inode on its unlinked list in a single
> transaction.  In order to maintain referential integrity of the XFS
> metadata, we cannot have an inode on the unlinked list with nlink >= 1.
>
> XFS and btrfs hack around d_tmpfile's behavior by creating the inode
> with nlink == 0 and then incrementing it just prior to calling
> d_tmpfile, anticipating that it will be reset to 0.
>
> Everywhere else outside of d_tmpfile, it appears that nlink updates and
> persistence is the responsibility of individual filesystems.  Therefore,
> move the nlink decrement out of d_tmpfile into the callers, and require
> that callers only pass in inodes with nlink already set to 0.
>
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/btrfs/inode.c  |    8 --------
>  fs/dcache.c       |    8 ++++++--
>  fs/ext2/namei.c   |    2 +-
>  fs/ext4/namei.c   |    1 +
>  fs/f2fs/namei.c   |    1 +
>  fs/minix/namei.c  |    2 +-
>  fs/ubifs/dir.c    |    1 +
>  fs/udf/namei.c    |    2 +-
>  fs/xfs/xfs_iops.c |   13 ++-----------
>  mm/shmem.c        |    1 +
>  10 files changed, 15 insertions(+), 24 deletions(-)
>
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 5c349667c761..bd189fc50f83 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -10382,14 +10382,6 @@ static int btrfs_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
>         if (ret)
>                 goto out;
>
> -       /*
> -        * We set number of links to 0 in btrfs_new_inode(), and here we set
> -        * it to 1 because d_tmpfile() will issue a warning if the count is 0,
> -        * through:
> -        *
> -        *    d_tmpfile() -> inode_dec_link_count() -> drop_nlink()
> -        */
> -       set_nlink(inode, 1);
>         d_tmpfile(dentry, inode);
>         unlock_new_inode(inode);
>         mark_inode_dirty(inode);
> diff --git a/fs/dcache.c b/fs/dcache.c
> index aac41adf4743..5fb4ecce2589 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -3042,12 +3042,16 @@ void d_genocide(struct dentry *parent)
>
>  EXPORT_SYMBOL(d_genocide);
>
> +/*
> + * Instantiate an inode in the dentry cache as a temporary file.  Callers must
> + * ensure that @inode has a zero link count.
> + */
>  void d_tmpfile(struct dentry *dentry, struct inode *inode)
>  {
> -       inode_dec_link_count(inode);
>         BUG_ON(dentry->d_name.name != dentry->d_iname ||
>                 !hlist_unhashed(&dentry->d_u.d_alias) ||
> -               !d_unlinked(dentry));
> +               !d_unlinked(dentry) ||
> +               inode->i_nlink != 0);

You've just promoted i_nlink filesystem accounting error (which
are not that rare) from WARN_ON() to BUG_ON(), not to mention
Linus' objection to any use of BUG_ON() at all.

!hlist_unhashed is anyway checked again in d_instantiate().
!d_unlinked is not a reason to break the machine.
The name check is really not a reason to break the machine.
Can probably make tmp name code conditional to WARN_ON().

Thanks,
Amir.

