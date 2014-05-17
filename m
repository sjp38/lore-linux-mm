Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id CE1B86B0036
	for <linux-mm@kvack.org>; Fri, 16 May 2014 20:47:43 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so3269640pbc.37
        for <linux-mm@kvack.org>; Fri, 16 May 2014 17:47:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tx10si10966760pac.112.2014.05.16.17.47.42
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 17:47:42 -0700 (PDT)
Date: Sat, 17 May 2014 08:46:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 446/499] security/keys/key.c:36:8: warning: excess
 elements in struct initializer
Message-ID: <5376b180.NmzHtL/zNwGnlnl9%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ff35dad6205c66d96feda494502753e5ed1b10f1
commit: 67039d034b422b074af336ebf8101346b6b5d441 [446/499] rwsem: Support optimistic spinning
config: make ARCH=tile tilegx_defconfig

All warnings:

>> security/keys/key.c:36:8: warning: excess elements in struct initializer [enabled by default]
>> security/keys/key.c:36:8: warning: (near initialization for 'key_types_sem') [enabled by default]
>> security/keys/key.c:36:8: warning: excess elements in struct initializer [enabled by default]
>> security/keys/key.c:36:8: warning: (near initialization for 'key_types_sem') [enabled by default]
--
>> security/keys/keyring.c:100:8: warning: excess elements in struct initializer [enabled by default]
>> security/keys/keyring.c:100:8: warning: (near initialization for 'keyring_serialise_link_sem') [enabled by default]
>> security/keys/keyring.c:100:8: warning: excess elements in struct initializer [enabled by default]
>> security/keys/keyring.c:100:8: warning: (near initialization for 'keyring_serialise_link_sem') [enabled by default]
--
>> fs/configfs/dir.c:38:1: warning: excess elements in struct initializer [enabled by default]
>> fs/configfs/dir.c:38:1: warning: (near initialization for 'configfs_rename_sem') [enabled by default]
>> fs/configfs/dir.c:38:1: warning: excess elements in struct initializer [enabled by default]
>> fs/configfs/dir.c:38:1: warning: (near initialization for 'configfs_rename_sem') [enabled by default]
--
>> net/rds/transport.c:41:8: warning: excess elements in struct initializer [enabled by default]
>> net/rds/transport.c:41:8: warning: (near initialization for 'rds_trans_sem') [enabled by default]
>> net/rds/transport.c:41:8: warning: excess elements in struct initializer [enabled by default]
>> net/rds/transport.c:41:8: warning: (near initialization for 'rds_trans_sem') [enabled by default]
--
>> fs/fscache/cache.c:18:1: warning: excess elements in struct initializer [enabled by default]
>> fs/fscache/cache.c:18:1: warning: (near initialization for 'fscache_addremove_sem') [enabled by default]
>> fs/fscache/cache.c:18:1: warning: excess elements in struct initializer [enabled by default]
>> fs/fscache/cache.c:18:1: warning: (near initialization for 'fscache_addremove_sem') [enabled by default]
--
>> drivers/hid/usbhid/hid-quirks.c:134:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/hid/usbhid/hid-quirks.c:134:8: warning: (near initialization for 'dquirks_rwsem') [enabled by default]
>> drivers/hid/usbhid/hid-quirks.c:134:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/hid/usbhid/hid-quirks.c:134:8: warning: (near initialization for 'dquirks_rwsem') [enabled by default]
--
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: (near initialization for '__i2c_board_lock') [enabled by default]
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/i2c/i2c-boardinfo.c:32:1: warning: (near initialization for '__i2c_board_lock') [enabled by default]
--
>> drivers/md/dm-target.c:17:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-target.c:17:8: warning: (near initialization for '_lock') [enabled by default]
>> drivers/md/dm-target.c:17:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-target.c:17:8: warning: (near initialization for '_lock') [enabled by default]
--
>> drivers/md/dm-ioctl.c:65:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-ioctl.c:65:8: warning: (near initialization for '_hash_lock') [enabled by default]
>> drivers/md/dm-ioctl.c:65:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-ioctl.c:65:8: warning: (near initialization for '_hash_lock') [enabled by default]
--
>> drivers/md/dm-path-selector.c:27:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-path-selector.c:27:8: warning: (near initialization for '_ps_lock') [enabled by default]
>> drivers/md/dm-path-selector.c:27:8: warning: excess elements in struct initializer [enabled by default]
>> drivers/md/dm-path-selector.c:27:8: warning: (near initialization for '_ps_lock') [enabled by default]
--
>> drivers/pci/search.c:16:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/pci/search.c:16:1: warning: (near initialization for 'pci_bus_sem') [enabled by default]
>> drivers/pci/search.c:16:1: warning: excess elements in struct initializer [enabled by default]
>> drivers/pci/search.c:16:1: warning: (near initialization for 'pci_bus_sem') [enabled by default]
..

vim +36 security/keys/key.c

^1da177e Linus Torvalds 2005-04-16  20  #include <linux/err.h>
^1da177e Linus Torvalds 2005-04-16  21  #include "internal.h"
^1da177e Linus Torvalds 2005-04-16  22  
8bc16dea David Howells  2011-08-22  23  struct kmem_cache *key_jar;
^1da177e Linus Torvalds 2005-04-16  24  struct rb_root		key_serial_tree; /* tree of keys indexed by serial */
^1da177e Linus Torvalds 2005-04-16  25  DEFINE_SPINLOCK(key_serial_lock);
^1da177e Linus Torvalds 2005-04-16  26  
^1da177e Linus Torvalds 2005-04-16  27  struct rb_root	key_user_tree; /* tree of quota records indexed by UID */
^1da177e Linus Torvalds 2005-04-16  28  DEFINE_SPINLOCK(key_user_lock);
^1da177e Linus Torvalds 2005-04-16  29  
0b77f5bf David Howells  2008-04-29  30  unsigned int key_quota_root_maxkeys = 200;	/* root's key count quota */
0b77f5bf David Howells  2008-04-29  31  unsigned int key_quota_root_maxbytes = 20000;	/* root's key space quota */
0b77f5bf David Howells  2008-04-29  32  unsigned int key_quota_maxkeys = 200;		/* general key count quota */
0b77f5bf David Howells  2008-04-29  33  unsigned int key_quota_maxbytes = 20000;	/* general key space quota */
0b77f5bf David Howells  2008-04-29  34  
^1da177e Linus Torvalds 2005-04-16  35  static LIST_HEAD(key_types_list);
^1da177e Linus Torvalds 2005-04-16 @36  static DECLARE_RWSEM(key_types_sem);
^1da177e Linus Torvalds 2005-04-16  37  
973c9f4f David Howells  2011-01-20  38  /* We serialise key instantiation and link */
76181c13 David Howells  2007-10-16  39  DEFINE_MUTEX(key_construction_mutex);
^1da177e Linus Torvalds 2005-04-16  40  
^1da177e Linus Torvalds 2005-04-16  41  #ifdef KEY_DEBUGGING
^1da177e Linus Torvalds 2005-04-16  42  void __key_check(const struct key *key)
^1da177e Linus Torvalds 2005-04-16  43  {
^1da177e Linus Torvalds 2005-04-16  44  	printk("__key_check: key %p {%08x} should be {%08x}\n",

:::::: The code at line 36 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
