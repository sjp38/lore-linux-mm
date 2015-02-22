Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 25BEA6B006E
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 13:32:19 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so20062586pdb.11
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 10:32:18 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q3si20816076pdj.219.2015.02.22.10.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 10:32:15 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/4] cleancache: remove limit on the number of cleancache enabled filesystems
Date: Sun, 22 Feb 2015 21:31:51 +0300
Message-ID: <cover.1424628280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Currently, maximal number of cleancache enabled filesystems equals 32,
which is insufficient nowadays, because a Linux host can have hundreds
of containers on board, each of which might want its own filesystem.
This patch set targets at removing this limitation - see patch 4 for
more details. Patches 1-3 prepare the code for this change.

Thanks,

Vladimir Davydov (4):
  ocfs2: copy fs uuid to superblock
  cleancache: zap uuid arg of cleancache_init_shared_fs
  cleancache: forbid overriding cleancache_ops
  cleancache: remove limit on the number of cleancache enabled
    filesystems

 Documentation/vm/cleancache.txt |    4 +-
 drivers/xen/tmem.c              |   16 ++-
 fs/ocfs2/super.c                |    4 +-
 fs/super.c                      |    2 +-
 include/linux/cleancache.h      |   13 +-
 mm/cleancache.c                 |  270 +++++++++++----------------------------
 6 files changed, 94 insertions(+), 215 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
