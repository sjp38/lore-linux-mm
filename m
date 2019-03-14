Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D76C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C23A2184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:09:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C23A2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F3708E0005; Thu, 14 Mar 2019 12:09:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65B088E0003; Thu, 14 Mar 2019 12:09:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D5688E0004; Thu, 14 Mar 2019 12:09:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2216E8E0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:09:08 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x63so5180624qka.5
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:09:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=c1LRYv3mDog891oXNfReucLaHboJeqZ1gJAuD/seqdk=;
        b=Sp/ERY9Y0xgaJZzrN74JdOkO6evtoDY76EhRt+vgxiQTkCktgFhQF0hjM8E2kK7u0z
         qXXlRux3bBWTxC0sLNuBjnGu8q27FYviap9BwGZ57oSa6/PN6qIgd0eggAty/pWXQtvX
         j5G5OQCnJje8W6IRSioHvnkJvKo+TfjRM+3wYcpzn1bsDOg0GaBdnAGSR9sQTi/fSSUA
         3YqfbWVsOjcHchwfHyID2S2XZkXBnWKozLOtD0V84uA4s/5rT81jMWMaeJJMI/cqFM0X
         Za+HP8YYyHclrc2F7OPsROY0y3aeQamKBnAAM0ljkN4mYbgn2wJp5mw+Ej2BsifQhLAr
         lRXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/NSA5NPV68+C1smA5lbyCz3VF8kRUkTpNN9E9jTxkxpdNXt9A
	MHoI2I/pFpT8oWNKo9aPiIIy7LaFjPDntFtCuWoxvZGRs6iXH5TYYAxE8DC/nvzlNPWhXOoarxq
	gFOjrb3AQzfkCw9IdV5tKaMG5I5fXT0WzWsloUKXqwzLsOQK5PIty/mZBHpGKkGUGig==
X-Received: by 2002:a0c:9924:: with SMTP id h33mr40703862qvd.156.1552579747871;
        Thu, 14 Mar 2019 09:09:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoChai2eMlLL4XG30pgoa1y4B2shxgrN2fQR1/tYL1Ei8+0L6QrUiw6qflElQMLAMejTyL
X-Received: by 2002:a0c:9924:: with SMTP id h33mr40703781qvd.156.1552579746720;
        Thu, 14 Mar 2019 09:09:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579746; cv=none;
        d=google.com; s=arc-20160816;
        b=zPKCDHIwnTRSZ0n9WDflzQk0V51Ef3m/G3WcTrlzBSJx9rJoHrSE10e8ierjTlypFi
         7R9vOkM6ifFLHwBTUT/hxkiePpBMHpIy7XchR/ZGbkwV4dnWmrsqRaYBTvwE9FsFsxKC
         MViBKYX9cZsjtN1L2nMJJqWtSU4gvoEj9+XGqaO95Hz+9Y9kDQO6rqjSM4BsGzVJyalC
         LfEdyXqC+aEHYX4w0sdErmY40alIrZbd3+Rk2dfaY3LsQePoZwPRhNsligULvjOBMHro
         8fPACT9rnvZQn4j8GMuVybt9+Q8QldIU53hSzTQBrz2QzP6DwmK7jRJn1TFOWLx4gNXA
         VV9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=c1LRYv3mDog891oXNfReucLaHboJeqZ1gJAuD/seqdk=;
        b=YR8CdvCXlShX1hOGDAyGXf7U/2AyzC4ktm2X75TXtyGNOML+uwIDiynjXbUip//Iup
         YYp9opZPo8ehM1DodTeSLnab7KN2FBIhrUXUuLJ875teHNfMVPIJ7q7qS3Kvbyd54l7G
         Cj8V7zcKW8yXluwps2/XL119jSaLLy6zeDt8itCejvZDfC0S1PNODpI6100jPT0hI9Or
         +FKsizeHwe4NDsFv1VOujiiONiv+wyml7jcYuiCeR7aDtVmLWvBLQaH0gc0M25l889i7
         kWH0FqE1fheHXFfxQKyce8JgJv9bXuKD6yjuSMWRpF9o3+kjQAZbWWpzVfyQ9IzeLSv+
         Ww6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c77si563712qkb.179.2019.03.14.09.09.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:09:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7B28B30894FB;
	Thu, 14 Mar 2019 16:09:04 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-148.rdu2.redhat.com [10.10.121.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BF1385C21F;
	Thu, 14 Mar 2019 16:08:45 +0000 (UTC)
Subject: [PATCH 00/38] VFS: Convert trivial filesystems and more
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-aio@kvack.org, Tony Luck <tony.luck@intel.com>,
 linux-efi@vger.kernel.org, Keith Busch <keith.busch@intel.com>,
 Josef Bacik <josef@toxicpanda.com>, Eric Paris <eparis@parisplace.org>,
 Vishal Verma <vishal.l.verma@intel.com>,
 "James E.J. Bottomley" <jejb@linux.ibm.com>, dri-devel@lists.freedesktop.org,
 virtualization@lists.linux-foundation.org,
 Trond Myklebust <trond.myklebust@hammerspace.com>, linux-mm@kvack.org,
 Arnd Bergmann <arnd@arndb.de>, David Airlie <airlied@linux.ie>,
 Matthew Garrett <matthew.garrett@nebula.com>, Joel Becker <jlbec@evilplan.org>,
 Christian Brauner <christian@brauner.io>, linux-ia64@vger.kernel.org,
 Chris Mason <clm@fb.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Nitin Gupta <ngupta@vflare.org>, Joel Fernandes <joel@joelfernandes.org>,
 devel@driverdev.osuosl.org, Dave Jiang <dave.jiang@intel.com>,
 Felipe Balbi <balbi@kernel.org>, linux-scsi@vger.kernel.org,
 linux-nvdimm@lists.01.org, Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Jeremy Kerr <jk@ozlabs.org>, Casey Schaufler <casey@schaufler-ca.com>,
 "Michael S. Tsirkin" <mst@redhat.com>, selinux@vger.kernel.org,
 "Martin K. Petersen" <martin.petersen@oracle.com>, oprofile-list@lists.sf.net,
 Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 xen-devel@lists.xenproject.org, Fenghua Yu <fenghua.yu@intel.com>,
 Jeff Layton <jlayton@kernel.org>, John Johansen <john.johansen@canonical.com>,
 Juergen Gross <jgross@suse.com>, Frederic Barrat <fbarrat@linux.ibm.com>,
 Stephen Smalley <sds@tycho.nsa.gov>, "J. Bruce Fields" <bfields@fieldses.org>,
 Hugh Dickins <hughd@google.com>, apparmor@lists.ubuntu.com,
 Andrew Donnellan <andrew.donnellan@au1.ibm.com>,
 Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>, Robert Richter <rric@kernel.org>,
 Uma Krishnan <ukrishn@linux.ibm.com>, "Matthew R. Ochs" <mrochs@linux.ibm.com>,
 Miklos Szeredi <miklos@szeredi.hu>, David Sterba <dsterba@suse.com>,
 Todd Kjos <tkjos@android.com>, linux-nfs@vger.kernel.org,
 Benjamin LaHaise <bcrl@kvack.org>, Martijn Coenen <maco@android.com>,
 Paul Moore <paul@paul-moore.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, Stefano Stabellini <sstabellini@kernel.org>,
 Dennis Dalessandro <dennis.dalessandro@intel.com>,
 Jason Wang <jasowang@redhat.com>, linux-rdma@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 Anna Schumaker <anna.schumaker@netapp.com>,
 Arve =?utf-8?b?SGrDuG5uZXbDpWc=?= <arve@android.com>,
 Minchan Kim <minchan@kernel.org>, "Manoj N. Kumar" <manoj@linux.ibm.com>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 linux-usb@vger.kernel.org, linux-btrfs@vger.kernel.org,
 Daniel Vetter <daniel@ffwll.ch>, dhowells@redhat.com,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 14 Mar 2019 16:08:44 +0000
Message-ID: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 14 Mar 2019 16:09:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Al,

Here's a set of patches that:

 (1) Provides a convenience member in struct fs_context that is OR'd into
     sb->s_iflags by sget_fc().

 (2) Provides a convenience vfs_init_pseudo_fs_context() helper function
     for doing most of the work in mounting a pseudo filesystem.

 (3) Converts all the trivial filesystems that have no arguments to
     fs_context.

 (4) Converts binderfs (which was trivial before January).

 (5) Converts ramfs, tmpfs, rootfs and devtmpfs.

 (6) Kills off mount_pseudo(), mount_pseudo_xattr(), mount_ns(),
     sget_userns().

The patches can be found here also:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git

on branch:

	mount-api-viro

David
---
David Howells (38):
      vfs: Provide sb->s_iflags settings in fs_context struct
      vfs: Provide a mount_pseudo-replacement for fs_context
      vfs: Convert aio to fs_context
      vfs: Convert anon_inodes to fs_context
      vfs: Convert bdev to fs_context
      vfs: Convert nsfs to fs_context
      vfs: Convert pipe to fs_context
      vfs: Convert zsmalloc to fs_context
      vfs: Convert sockfs to fs_context
      vfs: Convert dax to fs_context
      vfs: Convert drm to fs_context
      vfs: Convert ia64 perfmon to fs_context
      vfs: Convert cxl to fs_context
      vfs: Convert ocxlflash to fs_context
      vfs: Convert virtio_balloon to fs_context
      vfs: Convert btrfs_test to fs_context
      vfs: Kill off mount_pseudo() and mount_pseudo_xattr()
      vfs: Use sget_fc() for pseudo-filesystems
      vfs: Convert binderfs to fs_context
      vfs: Convert nfsctl to fs_context
      vfs: Convert rpc_pipefs to fs_context
      vfs: Kill off mount_ns()
      vfs: Kill sget_userns()
      vfs: Convert binfmt_misc to fs_context
      vfs: Convert configfs to fs_context
      vfs: Convert efivarfs to fs_context
      vfs: Convert fusectl to fs_context
      vfs: Convert qib_fs/ipathfs to fs_context
      vfs: Convert ibmasmfs to fs_context
      vfs: Convert oprofilefs to fs_context
      vfs: Convert gadgetfs to fs_context
      vfs: Convert xenfs to fs_context
      vfs: Convert openpromfs to fs_context
      vfs: Convert apparmorfs to fs_context
      vfs: Convert securityfs to fs_context
      vfs: Convert selinuxfs to fs_context
      vfs: Convert smackfs to fs_context
      tmpfs, devtmpfs, ramfs, rootfs: Convert to fs_context


 arch/ia64/kernel/perfmon.c         |   14 +
 drivers/android/binderfs.c         |  173 +++++++++-------
 drivers/base/devtmpfs.c            |   16 +
 drivers/dax/super.c                |   13 +
 drivers/gpu/drm/drm_drv.c          |   14 +
 drivers/infiniband/hw/qib/qib_fs.c |   26 ++
 drivers/misc/cxl/api.c             |   10 -
 drivers/misc/ibmasm/ibmasmfs.c     |   21 +-
 drivers/oprofile/oprofilefs.c      |   20 +-
 drivers/scsi/cxlflash/ocxl_hw.c    |   21 +-
 drivers/usb/gadget/legacy/inode.c  |   21 +-
 drivers/virtio/virtio_balloon.c    |   19 +-
 drivers/xen/xenfs/super.c          |   21 +-
 fs/aio.c                           |   15 +
 fs/anon_inodes.c                   |   12 +
 fs/binfmt_misc.c                   |   20 +-
 fs/block_dev.c                     |   14 +
 fs/btrfs/tests/btrfs-tests.c       |   13 +
 fs/configfs/mount.c                |   20 +-
 fs/efivarfs/super.c                |   20 +-
 fs/fuse/control.c                  |   20 +-
 fs/libfs.c                         |   91 ++++++--
 fs/nfsd/nfsctl.c                   |   33 ++-
 fs/nsfs.c                          |   13 +
 fs/openpromfs/inode.c              |   20 +-
 fs/pipe.c                          |   12 +
 fs/ramfs/inode.c                   |  104 ++++++---
 fs/super.c                         |  106 ++--------
 include/linux/fs.h                 |   21 --
 include/linux/fs_context.h         |    8 +
 include/linux/ramfs.h              |    6 -
 include/linux/shmem_fs.h           |    4 
 init/do_mounts.c                   |   12 -
 mm/shmem.c                         |  396 ++++++++++++++++++++++++------------
 mm/zsmalloc.c                      |   19 +-
 net/socket.c                       |   14 +
 net/sunrpc/rpc_pipe.c              |   34 ++-
 security/apparmor/apparmorfs.c     |   20 +-
 security/inode.c                   |   21 +-
 security/selinux/selinuxfs.c       |   20 +-
 security/smack/smackfs.c           |   34 ++-
 41 files changed, 902 insertions(+), 609 deletions(-)

