Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E36BD6B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 00:41:25 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y130-v6so2663658qka.1
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 21:41:25 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d57-v6si4387711qtk.6.2018.07.01.21.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 21:41:25 -0700 (PDT)
Subject: Re: [PATCH v2 4/6] mm/fs: add a sync_mode param for
 clear_page_dirty_for_io()
References: <20180702005654.20369-5-jhubbard@nvidia.com>
 <201807020900.J6omiRbx%fengguang.wu@intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b98be1bd-89dd-8b76-20f6-8f440dc3ba44@nvidia.com>
Date: Sun, 1 Jul 2018 21:40:22 -0700
MIME-Version: 1.0
In-Reply-To: <201807020900.J6omiRbx%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>, john.hubbard@gmail.com
Cc: kbuild-all@01.org, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/01/2018 07:47 PM, kbuild test robot wrote:
> Hi John,
> 
> Thank you for the patch! Yet something to improve:
> 
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.18-rc3]
> [cannot apply to next-20180629]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/john-hubbard-gmail-com/mm-fs-gup-don-t-unmap-or-drop-filesystem-buffers/20180702-090125
> config: i386-randconfig-x075-201826 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    fs/f2fs/dir.c: In function 'f2fs_delete_entry':
>>> fs/f2fs/dir.c:734:33: error: 'WB_SYNC_ALL' undeclared (first use in this function); did you mean 'FS_SYNC_FL'?
>       clear_page_dirty_for_io(page, WB_SYNC_ALL);
>                                     ^~~~~~~~~~~
>                                     FS_SYNC_FL

Fixed locally, via:

diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 258f9dc117f4..ca20c1262582 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -16,6 +16,7 @@
 #include "acl.h"
 #include "xattr.h"
 #include <trace/events/f2fs.h>
+#include <linux/writeback.h>
 
 static unsigned long dir_blocks(struct inode *inode)
 {



thanks,
-- 
John Hubbard
NVIDIA
