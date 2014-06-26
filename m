Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E1E506B003A
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 08:59:18 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so3174603pad.27
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 05:59:18 -0700 (PDT)
Received: from sjc00mx1.hgst.com (sjc00mx1.hitachigst.com. [199.255.44.36])
        by mx.google.com with ESMTPS id hs1si9753946pac.33.2014.06.26.05.59.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Jun 2014 05:59:17 -0700 (PDT)
Message-ID: <53AC1919.60905@hgst.com>
Date: Thu, 26 Jun 2014 16:59:05 +0400
From: Vyacheslav Dubeyko <Vyacheslav.Dubeyko@hgst.com>
MIME-Version: 1.0
Subject: Re: [mmotm:master 212/319] fs/nilfs2/sysfs.c:256:1: sparse: symbol
 'nilfs_sysfs_create_mounted_snapshots_group' was not declared. Should it
 be static?
References: <53abdbf7.4djbeHCO91dyNSec%fengguang.wu@intel.com>
In-Reply-To: <53abdbf7.4djbeHCO91dyNSec%fengguang.wu@intel.com>
Content-Type: multipart/mixed;
	boundary="------------040901070409090503040700"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

--------------040901070409090503040700
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit


On 06/26/2014 12:38 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
> commit: c4d5ec2ba1ab268de64dcad7c6544d99a2218999 [212/319] nilfs2: integrate sysfs support into driver
> reproduce: make C=1 CF=-D__CHECK_ENDIAN__
>
>
> sparse warnings: (new ones prefixed by >>)
>
>>> fs/nilfs2/sysfs.c:256:1: sparse: symbol 'nilfs_sysfs_create_mounted_snapshots_group' was not declared. Should it be static?
>>> fs/nilfs2/sysfs.c:369:1: sparse: symbol 'nilfs_sysfs_create_checkpoints_group' was not declared. Should it be static?
>>> fs/nilfs2/sysfs.c:458:1: sparse: symbol 'nilfs_sysfs_create_segments_group' was not declared. Should it be static?
>>> fs/nilfs2/sysfs.c:720:1: sparse: symbol 'nilfs_sysfs_create_segctor_group' was not declared. Should it be static?
>>> fs/nilfs2/sysfs.c:846:1: sparse: symbol 'nilfs_sysfs_create_superblock_group' was not declared. Should it be static?
> Please consider folding the attached diff :-)

The diff looks good for me. But what about to fix the issue in the source?
Please, find my vision of the patch in the attachment.

Thanks,
Vyacheslav Dubeyko.


--------------040901070409090503040700
Content-Type: text/x-patch;
	name="0001-nilfs2-nilfs_sysfs_create_mounted_snapshots_group-ca.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-nilfs2-nilfs_sysfs_create_mounted_snapshots_group-ca.pa";
	filename*1="tch"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] nilfs2: nilfs_sysfs_create_mounted_snapshots_group can be static
TO: Vyacheslav Dubeyko <Vyacheslav.Dubeyko@hgst.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-nilfs@vger.kernel.org
CC: linux-kernel@vger.kernel.org

CC: Vyacheslav Dubeyko <Vyacheslav.Dubeyko@hgst.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 fs/nilfs2/sysfs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nilfs2/sysfs.c b/fs/nilfs2/sysfs.c
index 0f6148c..bbb0dcc 100644
--- a/fs/nilfs2/sysfs.c
+++ b/fs/nilfs2/sysfs.c
@@ -87,7 +87,7 @@ static struct kobj_type nilfs_##name##_ktype = { \
 };
 
 #define NILFS_DEV_INT_GROUP_FNS(name, parent_name) \
-int nilfs_sysfs_create_##name##_group(struct the_nilfs *nilfs) \
+static int nilfs_sysfs_create_##name##_group(struct the_nilfs *nilfs) \
 { \
 	struct kobject *parent; \
 	struct kobject *kobj; \
@@ -106,7 +106,7 @@ int nilfs_sysfs_create_##name##_group(struct the_nilfs *nilfs) \
 		return err; \
 	return 0; \
 } \
-void nilfs_sysfs_delete_##name##_group(struct the_nilfs *nilfs) \
+static void nilfs_sysfs_delete_##name##_group(struct the_nilfs *nilfs) \
 { \
 	kobject_del(&nilfs->ns_##parent_name##_subgroups->sg_##name##_kobj); \
 }
-- 
1.7.9.5


--------------040901070409090503040700--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
