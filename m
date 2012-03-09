From: Andor Daam <andor.daam@googlemail.com>
Subject: ext3/4, btrfs, ocfs2: How to assure that cleancache_invalidate_fs is
 called on every superblock free
Date: Fri, 9 Mar 2012 14:40:22 +0100
Message-ID: <CACQs63L2wfXKaD5sH6OOV+Bm_+37F3QOdt1QMFbWnB9AE4iCpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <linux-ext4-owner@vger.kernel.org>
Sender: linux-ext4-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com
Cc: dan.magenheimer@oracle.com, fschmaus@gmail.com, linux-mm@kvack.org, ilendir@googlemail.com, sjenning@linux.vnet.ibm.com, konrad.wilk@oracle.com, i4passt@lists.informatik.uni-erlangen.de, ngupta@vflare.org
List-Id: linux-mm.kvack.org

Hello,

Is it ever possible for a superblock for a mounted filesystem to be
free'd without a previous call to unmount the filesystem?
I need to be certain that the function cleancache_invalidate_fs, which
is at the moment called by deactivate_locked_super (fs/super.c) [1],
is called before every free on a superblock of cleancache-enabled
filesystems.
Is this already the case or are there situations in which this does not happen?

It would be interesting to know this, as we are planning to have
cleancache save pointers to superblocks of every mounted
cleancache-enabled filesystem [2] and it would be fatal if a
superblock is free'd without cleancache being notified.

Regards
Andor

[1] commit c515e1fd361c2a08a9c2eb139396ec30a4f477dc
[2] http://marc.info/?l=linux-mm&m=133122649732669&w=2
