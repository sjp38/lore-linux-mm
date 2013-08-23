Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E14046B0068
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 22:51:13 -0400 (EDT)
From: Rui Xiang <rui.xiang@huawei.com>
Subject: [PATCH 0/2] fs: supply inode uid/gid setting interface
Date: Fri, 23 Aug 2013 10:48:36 +0800
Message-ID: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-rdma@vger.kernel.org, linux-usb@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linux-mm@kvack.org, cgroups@vger.kernel.org, netdev@vger.kernel.org, Rui Xiang <rui.xiang@huawei.com>

This patchset implements an accessor functions to set uid/gid
in inode struct. Just finish code clean up.

Rui Xiang (2):
  fs: implement inode uid/gid setting function
  fs: use inode_set_user to set uid/gid of inode

 arch/ia64/kernel/perfmon.c                |  3 +--
 arch/powerpc/platforms/cell/spufs/inode.c |  3 +--
 arch/s390/hypfs/inode.c                   |  3 +--
 drivers/infiniband/hw/qib/qib_fs.c        |  3 +--
 drivers/usb/gadget/f_fs.c                 |  3 +--
 drivers/usb/gadget/inode.c                |  5 +++--
 fs/9p/vfs_inode.c                         |  6 ++----
 fs/adfs/inode.c                           |  3 +--
 fs/affs/inode.c                           |  6 ++----
 fs/afs/inode.c                            |  6 ++----
 fs/anon_inodes.c                          |  3 +--
 fs/autofs4/inode.c                        |  4 ++--
 fs/befs/linuxvfs.c                        |  8 ++++----
 fs/ceph/caps.c                            |  5 +++--
 fs/ceph/inode.c                           |  8 ++++----
 fs/cifs/inode.c                           |  6 ++----
 fs/configfs/inode.c                       |  3 +--
 fs/debugfs/inode.c                        |  3 +--
 fs/devpts/inode.c                         |  7 +++----
 fs/ext2/ialloc.c                          |  3 +--
 fs/ext3/ialloc.c                          |  3 +--
 fs/ext4/ialloc.c                          |  3 +--
 fs/fat/inode.c                            |  6 ++----
 fs/fuse/control.c                         |  3 +--
 fs/fuse/inode.c                           |  4 ++--
 fs/hfs/inode.c                            |  6 ++----
 fs/hfsplus/inode.c                        |  3 +--
 fs/hpfs/inode.c                           |  3 +--
 fs/hpfs/namei.c                           | 12 ++++--------
 fs/hugetlbfs/inode.c                      |  3 +--
 fs/inode.c                                |  7 +++++++
 fs/isofs/inode.c                          |  3 +--
 fs/isofs/rock.c                           |  3 +--
 fs/ncpfs/inode.c                          |  3 +--
 fs/nfs/inode.c                            |  4 ++--
 fs/ntfs/inode.c                           | 12 ++++--------
 fs/ntfs/mft.c                             |  3 +--
 fs/ntfs/super.c                           |  3 +--
 fs/ocfs2/refcounttree.c                   |  3 +--
 fs/omfs/inode.c                           |  3 +--
 fs/pipe.c                                 |  3 +--
 fs/proc/base.c                            | 15 +++++----------
 fs/proc/fd.c                              |  8 ++++----
 fs/proc/inode.c                           |  3 +--
 fs/proc/self.c                            |  3 +--
 fs/stack.c                                |  3 +--
 fs/sysfs/inode.c                          |  3 +--
 fs/xfs/xfs_iops.c                         |  4 ++--
 include/linux/fs.h                        |  1 +
 ipc/mqueue.c                              |  3 +--
 kernel/cgroup.c                           |  3 +--
 mm/shmem.c                                |  3 +--
 net/socket.c                              |  3 +--
 53 files changed, 94 insertions(+), 142 deletions(-)

-- 
1.8.2.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
