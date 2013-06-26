Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id BB74E6B0036
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 02:30:09 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id er20so13252394lab.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2013 23:30:07 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH 0/2] fixes for list_lru
Date: Wed, 26 Jun 2013 02:29:39 -0400
Message-Id: <1372228181-18827-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, dchinner@redhat.com, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>

Hi Andrew,

I can't find those fixes - or replies to it - anywehere.
Maybe I just forgot to hit send ? If that is the case, sorry
about that.

I am resending just in case. They are supposed to be
folded to their respective patches:
- inode-convert-inode-lru-list-to-generic-lru-list-code.patch
- list_lru-dynamically-adjust-node-arrays.patch

Thanks


Glauber Costa (2):
  inode: move inode to a different list inside lock
  super: fix for destroy lrus

 fs/inode.c       | 2 +-
 fs/super.c       | 3 +++
 fs/xfs/xfs_buf.c | 2 +-
 fs/xfs/xfs_qm.c  | 2 +-
 4 files changed, 6 insertions(+), 3 deletions(-)

-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
