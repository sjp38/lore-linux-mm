Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id AABAE6B0036
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 06:10:31 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id q1so885901lam.26
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 03:10:31 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id dd6si2283586lac.4.2014.09.03.03.10.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Sep 2014 03:10:29 -0700 (PDT)
Subject: [PATCH 0/2] fuse: fix regression in fuse_get_user_pages()
From: Maxim Patlasov <MPatlasov@parallels.com>
Date: Wed, 03 Sep 2014 14:10:23 +0400
Message-ID: <20140903100826.23218.95122.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk
Cc: miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, werner.baumann@onlinehome.de

Hi,

The patchset fixes a regression introduced by the following commits:

c7f3888ad7f0 ("switch iov_iter_get_pages() to passing maximal number of pages")
c9c37e2e6378 ("fuse: switch to iov_iter_get_pages()")

The regression manifests itslef like this (thanks to Werner Baumann for reporting):

> davfs2 uses the fuse kernel module directly (not using the fuse
> userspace library). A user of davfs2 reported this problem
> (http://savannah.nongnu.org/support/?108640):
> 
> dd if=/dev/zero of=/mnt/owncloud/test.txt bs=20416 count=1
> works fine, but
> dd if=/dev/zero of=/mnt/owncloud/test.txt bs=20417 count=1
> fails.

Thanks,
Maxim

---

Maxim Patlasov (2):
      vfs: switch iov_iter_get_pages() to passing maximal size
      fuse: fuse_get_user_pages(): do not pack more data than requested


 fs/direct-io.c      |    2 +-
 fs/fuse/file.c      |   13 +++++++++----
 include/linux/uio.h |    2 +-
 mm/iov_iter.c       |   17 +++++++++--------
 4 files changed, 20 insertions(+), 14 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
