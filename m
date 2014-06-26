Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4136B0037
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 04:41:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so2865722pbc.14
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 01:41:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id sd3si8820496pac.94.2014.06.26.01.41.00
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 01:41:00 -0700 (PDT)
Date: Thu, 26 Jun 2014 16:38:15 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 212/319] fs/nilfs2/sysfs.c:256:1: sparse: symbol
 'nilfs_sysfs_create_mounted_snapshots_group' was not declared. Should it be static?
Message-ID: <53abdbf7.4djbeHCO91dyNSec%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_53abdbf7.l4ueiEf66KseJoA5ts7i80NjlZddh98h/E1CsfQzc/rWOn0K"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vyacheslav Dubeyko <Vyacheslav.Dubeyko@hgst.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_53abdbf7.l4ueiEf66KseJoA5ts7i80NjlZddh98h/E1CsfQzc/rWOn0K
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   9477ec75947f2cf0fc47e8ab781a5e9171099be2
commit: c4d5ec2ba1ab268de64dcad7c6544d99a2218999 [212/319] nilfs2: integrate sysfs support into driver
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/nilfs2/sysfs.c:256:1: sparse: symbol 'nilfs_sysfs_create_mounted_snapshots_group' was not declared. Should it be static?
>> fs/nilfs2/sysfs.c:369:1: sparse: symbol 'nilfs_sysfs_create_checkpoints_group' was not declared. Should it be static?
>> fs/nilfs2/sysfs.c:458:1: sparse: symbol 'nilfs_sysfs_create_segments_group' was not declared. Should it be static?
>> fs/nilfs2/sysfs.c:720:1: sparse: symbol 'nilfs_sysfs_create_segctor_group' was not declared. Should it be static?
>> fs/nilfs2/sysfs.c:846:1: sparse: symbol 'nilfs_sysfs_create_superblock_group' was not declared. Should it be static?

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_53abdbf7.l4ueiEf66KseJoA5ts7i80NjlZddh98h/E1CsfQzc/rWOn0K
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-c4d5ec2ba1ab268de64dcad7c6544d99a2218999.diff"

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
 sysfs.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nilfs2/sysfs.c b/fs/nilfs2/sysfs.c
index 0f6148c..46ca55b 100644
--- a/fs/nilfs2/sysfs.c
+++ b/fs/nilfs2/sysfs.c
@@ -253,7 +253,7 @@ static struct attribute *nilfs_mounted_snapshots_attrs[] = {
 
 NILFS_DEV_INT_GROUP_OPS(mounted_snapshots, dev);
 NILFS_DEV_INT_GROUP_TYPE(mounted_snapshots, dev);
-NILFS_DEV_INT_GROUP_FNS(mounted_snapshots, dev);
+static NILFS_DEV_INT_GROUP_FNS(mounted_snapshots, dev);
 
 /************************************************************************
  *                      NILFS checkpoints attrs                         *
@@ -366,7 +366,7 @@ static struct attribute *nilfs_checkpoints_attrs[] = {
 
 NILFS_DEV_INT_GROUP_OPS(checkpoints, dev);
 NILFS_DEV_INT_GROUP_TYPE(checkpoints, dev);
-NILFS_DEV_INT_GROUP_FNS(checkpoints, dev);
+static NILFS_DEV_INT_GROUP_FNS(checkpoints, dev);
 
 /************************************************************************
  *                        NILFS segments attrs                          *
@@ -455,7 +455,7 @@ static struct attribute *nilfs_segments_attrs[] = {
 
 NILFS_DEV_INT_GROUP_OPS(segments, dev);
 NILFS_DEV_INT_GROUP_TYPE(segments, dev);
-NILFS_DEV_INT_GROUP_FNS(segments, dev);
+static NILFS_DEV_INT_GROUP_FNS(segments, dev);
 
 /************************************************************************
  *                        NILFS segctor attrs                           *
@@ -717,7 +717,7 @@ static struct attribute *nilfs_segctor_attrs[] = {
 
 NILFS_DEV_INT_GROUP_OPS(segctor, dev);
 NILFS_DEV_INT_GROUP_TYPE(segctor, dev);
-NILFS_DEV_INT_GROUP_FNS(segctor, dev);
+static NILFS_DEV_INT_GROUP_FNS(segctor, dev);
 
 /************************************************************************
  *                        NILFS superblock attrs                        *
@@ -843,7 +843,7 @@ static struct attribute *nilfs_superblock_attrs[] = {
 
 NILFS_DEV_INT_GROUP_OPS(superblock, dev);
 NILFS_DEV_INT_GROUP_TYPE(superblock, dev);
-NILFS_DEV_INT_GROUP_FNS(superblock, dev);
+static NILFS_DEV_INT_GROUP_FNS(superblock, dev);
 
 /************************************************************************
  *                        NILFS device attrs                            *

--=_53abdbf7.l4ueiEf66KseJoA5ts7i80NjlZddh98h/E1CsfQzc/rWOn0K--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
