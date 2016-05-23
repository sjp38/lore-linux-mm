Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4B716B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 07:53:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b124so19279190pfb.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 04:53:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id u26si51480217pfa.38.2016.05.23.04.53.51
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 04:53:51 -0700 (PDT)
Date: Mon, 23 May 2016 19:52:37 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 7/8] pipe: account to kmemcg
Message-ID: <201605231937.F5zGihN1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Content-Disposition: inline
In-Reply-To: <9e5dd7673dc37f198615b717fb1eae9309115134.1463997354.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[auto build test ERROR on next-20160520]
[cannot apply to tip/x86/core net-next/master v4.6-rc7 v4.6-rc6 v4.6-rc5 v4.6]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Vladimir-Davydov/mm-remove-pointless-struct-in-struct-page-definition/20160523-182939
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

Note: the linux-review/Vladimir-Davydov/mm-remove-pointless-struct-in-struct-page-definition/20160523-182939 HEAD 08a247942f52ec5444ba2a0d3c951358640eccf5 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   fs/built-in.o: In function `anon_pipe_buf_steal':
>> fs/pipe.c:147: undefined reference to `memcg_kmem_uncharge'
   collect2: error: ld returned 1 exit status

vim +147 fs/pipe.c

   141	static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
   142				       struct pipe_buffer *buf)
   143	{
   144		struct page *page = buf->page;
   145	
   146		if (page_count(page) == 1) {
 > 147			memcg_kmem_uncharge(page, 0);
   148			__ClearPageKmemcg(page);
   149			__SetPageLocked(page);
   150			return 0;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--+HP7ph2BbKc20aGI
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--+HP7ph2BbKc20aGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
