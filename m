Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1D05C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 930FF20657
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 17:16:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 930FF20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B6458E0002; Wed, 19 Jun 2019 13:16:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33FC18E0001; Wed, 19 Jun 2019 13:16:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22DE78E0002; Wed, 19 Jun 2019 13:16:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2CDD8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:16:47 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c1so15057147qkl.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:16:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=9iK5/w6ZrnUqKACiM3YTFCow2frMFm7yE4ZZQhTwn1Q=;
        b=i9M7wisV9Qm8H0WWxqsHCHY2nb70/s815Q6M9a8Op+Vtb0fAqBeq2ZK+qp17sNSFSb
         SSITNdprkY6TWFXbB6gr4Jo376IrZdychZ30rauwAJZ9Bj+aOIxEuX8r+lCky+IWxizs
         9utVDGu2+JBZEbaU47XV3Jtx3yCj7HJOhOW5cMBBLGUwQfM4PxWcsc57PiN0Znz6z1ki
         Y9DIBLf3fX5aUPJFqGMlrf2ItSgysAaFUJE1oLALRCL4R7rCND+mJz8z0+vkOMtF8trn
         /TyGJGVDHJCJLyCjBekae0cUEcr73+c5yvJUVCwzaYulLB3PnkyEdVbe0Yurma+s3dlG
         SdMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjCTqvWghwHHuZ1P+FOekSKGzeRhe1zaunppTIv4m56xe5a8eb
	Eq/rXdI9PzVT36z8syYi896VkuaXRkq2jptLAA2HeyJJZDOriTJ16KlY0yBoZvW9GgStYM9SbbS
	oP/mOWecM1ruaIETy/oouLOPyjYMU2/eGu1Hi4gDROWbmCTWFKSpdi2dpNhzTSu2WyQ==
X-Received: by 2002:a0c:d941:: with SMTP id t1mr23852954qvj.176.1560964607749;
        Wed, 19 Jun 2019 10:16:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbNe5/9jTOxRBGdQgWFMD0Uv+rd5qEGTfZUwqv06IIbqI4JkQbk3AoC2rCf8zsomki30I9
X-Received: by 2002:a0c:d941:: with SMTP id t1mr23852868qvj.176.1560964606684;
        Wed, 19 Jun 2019 10:16:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560964606; cv=none;
        d=google.com; s=arc-20160816;
        b=uCyOBIoMnTHdi7o3LcqGjne6IW86fT2bFUh2kk+e3i3EtYLAPc0EXASYeHCc75S7bK
         Ysgx5JRoUcYx0XylwmDOG9UYobXQ6EgTRnaZ83bT8qjZvx9rVBMg9UkuWbaHYAUN+9Hh
         JP72zfC17Uor4KybAUzPPlS3KZKX2zLV0plkYBYDLSUcJoIU7QGBa+N1J1imUduupamd
         XFjqIlWBVj/fMDrZl9wvE+BAngAb/TtNAa4p+uupYg3CUnCaCsovyNx8qahiBzoY22pA
         63DqEj5a2NAsEOOLi2il4NBSagJ8pSDPsiNA4+tmFEZMEFvYqDReB2WZOjDtb/8QSAC0
         uGXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=9iK5/w6ZrnUqKACiM3YTFCow2frMFm7yE4ZZQhTwn1Q=;
        b=XMJJ8SkaXICdfwdUN0aJIDAGdJDr/a3o84wxQDs1+n+lmYuwelXQj1BX+M6kDVkyMd
         EhHYaGinRCZmxVvl5LIfkB6FB2n6T8JJqvwg4sSgUpSHwEmhHybirf/BiYLQOec1mQ7g
         rsqL+YXzPw7+nQL1JK2j5mdu9NIXdcYfFW/pVReirvHRiqKmWBmURSglgejZlUaatDlp
         8cTOLi/A7YGzNZY3qggx60/NC4mNL8wNvPzRGNNVVejznI767pV3fNwpcZGsxdaMJOnR
         XT5jSRHPLbNiyDzlhFOCMfJiXictT/Bl4kr0TRG9AMfrHL+W3qsTXX05Jt/her0e7lfD
         69ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t46si3266587qtc.88.2019.06.19.10.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 10:16:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 52BE4821C3;
	Wed, 19 Jun 2019 17:16:35 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 15C105D71B;
	Wed, 19 Jun 2019 17:16:29 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH v2] mm, memcg: Add a memcg_slabinfo debugfs file
Date: Wed, 19 Jun 2019 13:16:21 -0400
Message-Id: <20190619171621.26209-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 19 Jun 2019 17:16:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are concerns about memory leaks from extensive use of memory
cgroups as each memory cgroup creates its own set of kmem caches. There
is a possiblity that the memcg kmem caches may remain even after the
memory cgroups have been offlined. Therefore, it will be useful to show
the status of each of memcg kmem caches.

This patch introduces a new <debugfs>/memcg_slabinfo file which is
somewhat similar to /proc/slabinfo in format, but lists only information
about kmem caches that have child memcg kmem caches. Information
available in /proc/slabinfo are not repeated in memcg_slabinfo.

A portion of a sample output of the file was:

  # <name> <css_id[:dead]> <active_objs> <num_objs> <active_slabs> <num_slabs>
  rpc_inode_cache   root          13     51      1      1
  rpc_inode_cache     48           0      0      0      0
  fat_inode_cache   root           1     45      1      1
  fat_inode_cache     41           2     45      1      1
  xfs_inode         root         770    816     24     24
  xfs_inode           92          22     34      1      1
  xfs_inode           88:dead      1     34      1      1
  xfs_inode           89:dead     23     34      1      1
  xfs_inode           85           4     34      1      1
  xfs_inode           84           9     34      1      1

The css id of the memcg is also listed. If a memcg is not online,
the tag ":dead" will be attached as shown above.

Suggested-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Waiman Long <longman@redhat.com>
---
 mm/slab_common.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..2bca1558a722 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -17,6 +17,7 @@
 #include <linux/uaccess.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
+#include <linux/debugfs.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
@@ -1498,6 +1499,62 @@ static int __init slab_proc_init(void)
 	return 0;
 }
 module_init(slab_proc_init);
+
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_MEMCG_KMEM)
+/*
+ * Display information about kmem caches that have child memcg caches.
+ */
+static int memcg_slabinfo_show(struct seq_file *m, void *unused)
+{
+	struct kmem_cache *s, *c;
+	struct slabinfo sinfo;
+
+	mutex_lock(&slab_mutex);
+	seq_puts(m, "# <name> <css_id[:dead]> <active_objs> <num_objs>");
+	seq_puts(m, " <active_slabs> <num_slabs>\n");
+	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
+		/*
+		 * Skip kmem caches that don't have any memcg children.
+		 */
+		if (list_empty(&s->memcg_params.children))
+			continue;
+
+		memset(&sinfo, 0, sizeof(sinfo));
+		get_slabinfo(s, &sinfo);
+		seq_printf(m, "%-17s root      %6lu %6lu %6lu %6lu\n",
+			   cache_name(s), sinfo.active_objs, sinfo.num_objs,
+			   sinfo.active_slabs, sinfo.num_slabs);
+
+		for_each_memcg_cache(c, s) {
+			struct cgroup_subsys_state *css;
+			char *dead = "";
+
+			css = &c->memcg_params.memcg->css;
+			if (!(css->flags & CSS_ONLINE))
+				dead = ":dead";
+
+			memset(&sinfo, 0, sizeof(sinfo));
+			get_slabinfo(c, &sinfo);
+			seq_printf(m, "%-17s %4d%5s %6lu %6lu %6lu %6lu\n",
+				   cache_name(c), css->id, dead,
+				   sinfo.active_objs, sinfo.num_objs,
+				   sinfo.active_slabs, sinfo.num_slabs);
+		}
+	}
+	mutex_unlock(&slab_mutex);
+	return 0;
+}
+DEFINE_SHOW_ATTRIBUTE(memcg_slabinfo);
+
+static int __init memcg_slabinfo_init(void)
+{
+	debugfs_create_file("memcg_slabinfo", S_IFREG | S_IRUGO,
+			    NULL, NULL, &memcg_slabinfo_fops);
+	return 0;
+}
+
+late_initcall(memcg_slabinfo_init);
+#endif /* CONFIG_DEBUG_FS && CONFIG_MEMCG_KMEM */
 #endif /* CONFIG_SLAB || CONFIG_SLUB_DEBUG */
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
-- 
2.18.1

