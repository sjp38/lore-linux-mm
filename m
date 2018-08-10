Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA6E6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 01:54:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e15-v6so4793393pfi.5
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 22:54:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 33-v6si7101243ply.251.2018.08.09.22.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 22:54:54 -0700 (PDT)
Date: Fri, 10 Aug 2018 13:54:31 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [mmotm:master 124/394] mm/vmscan.c:410:15: error: 'shrinker_idr'
 undeclared; did you mean 'shrinker_list'?
Message-ID: <201808101327.UMjeeNfi%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   b1da01df1aa700864692a49a7007fc96cc1da7d9
commit: f9ee2a2d698cd64d8032d56649e960a91bb98416 [124/394] mm: use special value SHRINKER_REGISTERING instead list_empty() check
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        git checkout f9ee2a2d698cd64d8032d56649e960a91bb98416
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the mmotm/master HEAD b1da01df1aa700864692a49a7007fc96cc1da7d9 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   mm/vmscan.c: In function 'register_shrinker_prepared':
>> mm/vmscan.c:410:15: error: 'shrinker_idr' undeclared (first use in this function); did you mean 'shrinker_list'?
     idr_replace(&shrinker_idr, shrinker, shrinker->id);
                  ^~~~~~~~~~~~
                  shrinker_list
   mm/vmscan.c:410:15: note: each undeclared identifier is reported only once for each function it appears in
>> mm/vmscan.c:410:47: error: 'struct shrinker' has no member named 'id'
     idr_replace(&shrinker_idr, shrinker, shrinker->id);
                                                  ^~

vim +410 mm/vmscan.c

   405	
   406	void register_shrinker_prepared(struct shrinker *shrinker)
   407	{
   408		down_write(&shrinker_rwsem);
   409		list_add_tail(&shrinker->list, &shrinker_list);
 > 410		idr_replace(&shrinker_idr, shrinker, shrinker->id);
   411		up_write(&shrinker_rwsem);
   412	}
   413	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--T4sUOijqQbZv57TR
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--T4sUOijqQbZv57TR--
