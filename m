Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF5AEC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:59:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ABA0216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:59:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=android.com header.i=@android.com header.b="lbzZFspY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ABA0216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=android.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDF508E000B; Wed, 31 Jul 2019 12:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8F0C8E0001; Wed, 31 Jul 2019 12:59:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D57DC8E000B; Wed, 31 Jul 2019 12:59:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1D9B8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:59:06 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so37809834pll.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:59:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oqrLFoRmuV3hwqUNXQJ2VzDrgthNlMLKsczJURhiFqM=;
        b=QAQFwHgLV7Yu3C8h3AudOQjDnuYQC+m/3KZR38sUKIh9ywCYlG19bfgGevGD/s9gaW
         Uvm13lSNLIv4i2YXWO+mFMJnhBlkILdY2W68BXmZXZ0sCtB1H8Q4FVAncs0U9wF7Oguf
         Xm6Xvp7tNY2dL7L07K8zEo9bG/jX96UaakMGnvlhReEOucrmyTSxM6FltuNKwqrYU7+N
         0yQIfa9OMN5buIaCi0GU1UACUa2PJrQeusaTZh5UGvurWKaqXWMEnCfiaQJWn51BKs2V
         Tee77erIZRPuTzhzHdKQBsEby6hzuOQwSJ5CozkILNQvBfHXyIv8oPD2WCbzk9PXmwvR
         L/5Q==
X-Gm-Message-State: APjAAAU6Xc7U2M06UsxDuwyQ0FAGjooJrCi+dwLM1U0BRODzoyrEEU4h
	mAiRDb8NX6lGlP1J/3LkQAfP01GunGL27U23KPkWa7X6DR52AnHDE038xOtDdU/fHiw61GlPiH8
	hg3pcdHYY8D9qeOwkZNWx1hmKj6waWhNLvIw6O87p7Vv7NsnijnVWHg6D1HlRYUjS0A==
X-Received: by 2002:a63:2264:: with SMTP id t36mr107779384pgm.87.1564592346200;
        Wed, 31 Jul 2019 09:59:06 -0700 (PDT)
X-Received: by 2002:a63:2264:: with SMTP id t36mr107779336pgm.87.1564592345370;
        Wed, 31 Jul 2019 09:59:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592345; cv=none;
        d=google.com; s=arc-20160816;
        b=R6EVghw8KEzWMMu6zKPcbMcbYsjGVfXnXBxJ+5N1bUJRVZQWRC+ZJxEpxdXz811dYr
         N6OnAS+SrZd9JWW9erB3jSJO1RntkIIyTd+XaXzy55Xry7DCIGkmg8X4LX7SXz664lLl
         0oaMHtSMqgQ0nIV3sWzgHYcYyI/LMB4QJeT1d0AK+m0ei0zS+0K4L62iuMZlgf7pHGID
         sQJULX2iLX/qsP5gTi7JukX97h4H9tZoPqNhh+YP4/S+x/U3wr12dFBZP7jJ1TxdH4/o
         PYYsRr3xkv/9GJvHDkc8nuUWRh0rmyefCUsz3gJCaSahx1h7d2l7ajCPS+TtREOqrEdc
         fLUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oqrLFoRmuV3hwqUNXQJ2VzDrgthNlMLKsczJURhiFqM=;
        b=AVhZGfjFBbj0Y9hcexRwmWno50v6jledSdmsq40M7gY/qR4qcldm3NJK96tm/Zsimm
         FqPHMQqqJ/B8v7caBLahcPd5TklZyELPh+Mm2WWLgugy7tXVFoxtbGIATGdrWwAp4ncL
         nKC129OiYRNaa/bvT8TRr4DZSoifo2FkeDVZAyTwFzXEhz2iSSojrqQeKDMxpCejKg0a
         BGdrcpO5nPPF7ieEKNgSQyRgAt+CFWosTGbQpceMdovlisIvCvXhpyBcJj06iueM4rAM
         IySpOH3KpR60/rdGTB5w8TSvxJ+SVfMZvrgD0kBXLf0/I2v4FvFUZsYVbHkoV6f6cf9H
         Rkbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=lbzZFspY;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor83278217plp.9.2019.07.31.09.59.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 09:59:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@android.com header.s=20161025 header.b=lbzZFspY;
       spf=pass (google.com: domain of salyzyn@android.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=salyzyn@android.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=android.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=android.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oqrLFoRmuV3hwqUNXQJ2VzDrgthNlMLKsczJURhiFqM=;
        b=lbzZFspYQPlTjS9mFxnpUUD9r+UIEx5grL+av4OuQPP9/T+2OU9ueuNWZmmx0kL25k
         h5cFZG3+lOBZ6FM+mRmt6orsCAbGiHe3PtPTc24ZDvFmF7WGaRiItz/C5sh28BlCEsev
         GzxXAOZZ+f5AZOt3ZpP2rjRtT4keWRuY8WPfybmuCd7s1ViVRKOuvo5jOslEHHZAXiE3
         StK/2PPcdxNitdPTPhhnXcvWDqz/ZBNn51yPMrmV0TzR+zsshmmqRgfYcIGGfn0BhJEo
         LPEOz1Kf/FYmGXc4HHzy/9Haiw4T1QgApXZXk8B2sYhj8mHRvQd5TF4do0geCp4hTfi+
         8L5g==
X-Google-Smtp-Source: APXvYqwhRaDtFua+d3o3hcvLc/U+pzzs9W5nxrOy9sfuhnDOsCUPlyOQjSC3Ot89UxpEV42mqzbN8g==
X-Received: by 2002:a17:902:204:: with SMTP id 4mr34818460plc.178.1564592344943;
        Wed, 31 Jul 2019 09:59:04 -0700 (PDT)
Received: from nebulus.mtv.corp.google.com ([2620:15c:211:200:5404:91ba:59dc:9400])
        by smtp.gmail.com with ESMTPSA id f72sm2245954pjg.10.2019.07.31.09.59.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 09:59:04 -0700 (PDT)
From: Mark Salyzyn <salyzyn@android.com>
To: linux-kernel@vger.kernel.org
Cc: kernel-team@android.com,
	Mark Salyzyn <salyzyn@android.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Jonathan Corbet <corbet@lwn.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	linux-unionfs@vger.kernel.org,
	linux-doc@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	David Howells <dhowells@redhat.com>,
	Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>,
	David Sterba <dsterba@suse.com>,
	Jeff Layton <jlayton@kernel.org>,
	Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	Steve French <sfrench@samba.org>,
	Tyler Hicks <tyhicks@canonical.com>,
	Jan Kara <jack@suse.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <yuchao0@huawei.com>,
	Bob Peterson <rpeterso@redhat.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Richard Weinberger <richard@nod.at>,
	Dave Kleikamp <shaggy@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tejun Heo <tj@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Hugh Dickins <hughd@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mathieu Malaterre <malat@debian.org>,
	"Ernesto A . Fernandez" <ernesto.mnd.fernandez@gmail.com>,
	Vyacheslav Dubeyko <slava@dubeyko.com>,
	v9fs-developer@lists.sourceforge.net,
	linux-afs@lists.infradead.org,
	linux-btrfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org,
	ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org,
	cluster-devel@redhat.com,
	linux-mtd@lists.infradead.org,
	jfs-discussion@lists.sourceforge.net,
	linux-nfs@vger.kernel.org,
	ocfs2-devel@oss.oracle.com,
	devel@lists.orangefs.org,
	reiserfs-devel@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v13 0/5] overlayfs override_creds=off
Date: Wed, 31 Jul 2019 09:58:01 -0700
Message-Id: <20190731165803.4755-7-salyzyn@android.com>
X-Mailer: git-send-email 2.22.0.770.g0f2c4a37fd-goog
In-Reply-To: <20190731165803.4755-1-salyzyn@android.com>
References: <20190731165803.4755-1-salyzyn@android.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Patch series:

overlayfs: check CAP_DAC_READ_SEARCH before issuing exportfs_decode_fh
Add flags option to get xattr method paired to __vfs_getxattr
overlayfs: handle XATTR_NOSECURITY flag for get xattr method
overlayfs: internal getxattr operations without sepolicy checking
overlayfs: override_creds=off option bypass creator_cred

The first four patches address fundamental security issues that should
be solved regardless of the override_creds=off feature.
on them).

The fifth adds the feature depends on these other fixes.

By default, all access to the upper, lower and work directories is the
recorded mounter's MAC and DAC credentials.  The incoming accesses are
checked against the caller's credentials.

If the principles of least privilege are applied for sepolicy, the
mounter's credentials might not overlap the credentials of the caller's
when accessing the overlayfs filesystem.  For example, a file that a
lower DAC privileged caller can execute, is MAC denied to the
generally higher DAC privileged mounter, to prevent an attack vector.

We add the option to turn off override_creds in the mount options; all
subsequent operations after mount on the filesystem will be only the
caller's credentials.  The module boolean parameter and mount option
override_creds is also added as a presence check for this "feature",
existence of /sys/module/overlay/parameters/overlay_creds

Signed-off-by: Mark Salyzyn <salyzyn@android.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Amir Goldstein <amir73il@gmail.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: linux-unionfs@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: David Howells <dhowells@redhat.com>
Cc: Chris Mason <clm@fb.com>
Cc: Josef Bacik <josef@toxicpanda.com>
Cc: David Sterba <dsterba@suse.com>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Sage Weil <sage@redhat.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Steve French <sfrench@samba.org>
Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: Jan Kara <jack@suse.com>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Dave Kleikamp <shaggy@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: Mark Fasheh <mark@fasheh.com>
Cc: Joel Becker <jlbec@evilplan.org>
Cc: Joseph Qi <joseph.qi@linux.alibaba.com>
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Phillip Lougher <phillip@squashfs.org.uk>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Ernesto A. Fernandez <ernesto.mnd.fernandez@gmail.com>
Cc: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: v9fs-developer@lists.sourceforge.net
Cc: linux-afs@lists.infradead.org
Cc: linux-btrfs@vger.kernel.org
Cc: ceph-devel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org
Cc: samba-technical@lists.samba.org
Cc: ecryptfs@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-fsdevel@vger.kernel.org
Cc: cluster-devel@redhat.com
Cc: linux-mtd@lists.infradead.org
Cc: jfs-discussion@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com
Cc: devel@lists.orangefs.org
Cc: reiserfs-devel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: netdev@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: stable@vger.kernel.org # 4.4, 4.9, 4.14 & 4.19
---
v13:
- add flags argument to __vfs_getxattr
- drop GFP_NOFS side-effect

v12:
- Restore squished out patch 2 and 3 in the series,
  then change algorithm to add flags argument.
  Per-thread flag is a large security surface.

v11:
- Squish out v10 introduced patch 2 and 3 in the series,
  then and use per-thread flag instead for nesting.
- Switch name to ovl_do_vds_getxattr for __vds_getxattr wrapper.
- Add sb argument to ovl_revert_creds to match future work.

v10:
- Return NULL on CAP_DAC_READ_SEARCH
- Add __get xattr method to solve sepolicy logging issue
- Drop unnecessary sys_admin sepolicy checking for administrative
  driver internal xattr functions.

v6:
- Drop CONFIG_OVERLAY_FS_OVERRIDE_CREDS.
- Do better with the documentation, drop rationalizations.
- pr_warn message adjusted to report consequences.

v5:
- beefed up the caveats in the Documentation
- Is dependent on
  "overlayfs: check CAP_DAC_READ_SEARCH before issuing exportfs_decode_fh"
  "overlayfs: check CAP_MKNOD before issuing vfs_whiteout"
- Added prwarn when override_creds=off

v4:
- spelling and grammar errors in text

v3:
- Change name from caller_credentials / creator_credentials to the
  boolean override_creds.
- Changed from creator to mounter credentials.
- Updated and fortified the documentation.
- Added CONFIG_OVERLAY_FS_OVERRIDE_CREDS

v2:
- Forward port changed attr to stat, resulting in a build error.
- altered commit message.

