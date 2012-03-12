Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id D29CA6B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 09:38:29 -0400 (EDT)
Date: Mon, 12 Mar 2012 14:38:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ext3/4, btrfs, ocfs2: How to assure that
 cleancache_invalidate_fs is called on every superblock free
Message-ID: <20120312133825.GF5998@quack.suse.cz>
References: <CACQs63L2wfXKaD5sH6OOV+Bm_+37F3QOdt1QMFbWnB9AE4iCpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACQs63L2wfXKaD5sH6OOV+Bm_+37F3QOdt1QMFbWnB9AE4iCpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andor Daam <andor.daam@googlemail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, dan.magenheimer@oracle.com, fschmaus@gmail.com, linux-mm@kvack.org, ilendir@googlemail.com, sjenning@linux.vnet.ibm.com, konrad.wilk@oracle.com, i4passt@lists.informatik.uni-erlangen.de, ngupta@vflare.org

  Hello,

On Fri 09-03-12 14:40:22, Andor Daam wrote:
> Is it ever possible for a superblock for a mounted filesystem to be
> free'd without a previous call to unmount the filesystem?
  No, I don't think so (well, except for cases where we do not manage to
fully setup the superblock). But be aware that mount/umount need not be
really the entry points you are looking for since filesystem can be mounted
several times. Rather deactivate_locked_supers() is the place you are
looking for...

> I need to be certain that the function cleancache_invalidate_fs, which is
> at the moment called by deactivate_locked_super (fs/super.c) [1], is
> called before every free on a superblock of cleancache-enabled
> filesystems.  Is this already the case or are there situations in which
> this does not happen?
> 
> It would be interesting to know this, as we are planning to have
> cleancache save pointers to superblocks of every mounted
> cleancache-enabled filesystem [2] and it would be fatal if a
> superblock is free'd without cleancache being notified.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
