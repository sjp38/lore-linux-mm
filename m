Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 679386B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 13:32:16 -0500 (EST)
Received: by padfa1 with SMTP id fa1so21832441pad.2
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 10:32:16 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id a9si868471pas.76.2015.02.22.10.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Feb 2015 10:32:15 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/4] ocfs2: copy fs uuid to superblock
Date: Sun, 22 Feb 2015 21:31:52 +0300
Message-ID: <298a285f81e5fa2c1320c74ecf9d2b44bb9fa36c.1424628280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1424628280.git.vdavydov@parallels.com>
References: <cover.1424628280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This will allow us to remove the uuid argument from
cleancache_init_shared_fs.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/ocfs2/super.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 26675185b886..43f5a9e71b35 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -2069,6 +2069,8 @@ static int ocfs2_initialize_super(struct super_block *sb,
 	cbits = le32_to_cpu(di->id2.i_super.s_clustersize_bits);
 	bbits = le32_to_cpu(di->id2.i_super.s_blocksize_bits);
 	sb->s_maxbytes = ocfs2_max_file_offset(bbits, cbits);
+	memcpy(sb->s_uuid, di->id2.i_super.s_uuid,
+	       sizeof(di->id2.i_super.s_uuid));
 
 	osb->osb_dx_mask = (1 << (cbits - bbits)) - 1;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
