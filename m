Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBA1F6B000C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:00:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a13-v6so1238865pfo.22
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:00:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b18-v6si4230127pls.292.2018.06.27.09.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 09:00:40 -0700 (PDT)
Date: Wed, 27 Jun 2018 23:59:37 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH V7 10/24] block: introduce multipage page bvec helpers
Message-ID: <201806272319.0p98i2TZ%fengguang.wu@intel.com>
References: <20180627124548.3456-11-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627124548.3456-11-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: kbuild-all@01.org, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

Hi Ming,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.18-rc2]
[cannot apply to next-20180627]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Ming-Lei/block-support-multipage-bvec/20180627-214022
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   net/ceph/messenger.c:842:25: sparse: expression using sizeof(void)
   net/ceph/messenger.c:842:25: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
   include/linux/bvec.h:140:32: sparse: expression using sizeof(void)
   include/linux/bvec.h:140:32: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
   net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>> net/ceph/messenger.c:890:47: sparse: too many warnings

vim +890 net/ceph/messenger.c

6aaa4511 Alex Elder      2013-03-06  862  
8ae4f4f5 Alex Elder      2013-03-14  863  static bool ceph_msg_data_bio_advance(struct ceph_msg_data_cursor *cursor,
8ae4f4f5 Alex Elder      2013-03-14  864  					size_t bytes)
6aaa4511 Alex Elder      2013-03-06  865  {
5359a17d Ilya Dryomov    2018-01-20  866  	struct ceph_bio_iter *it = &cursor->bio_iter;
6aaa4511 Alex Elder      2013-03-06  867  
5359a17d Ilya Dryomov    2018-01-20  868  	BUG_ON(bytes > cursor->resid);
5359a17d Ilya Dryomov    2018-01-20  869  	BUG_ON(bytes > bio_iter_len(it->bio, it->iter));
25aff7c5 Alex Elder      2013-03-11  870  	cursor->resid -= bytes;
5359a17d Ilya Dryomov    2018-01-20  871  	bio_advance_iter(it->bio, &it->iter, bytes);
f38a5181 Kent Overstreet 2013-08-07  872  
5359a17d Ilya Dryomov    2018-01-20  873  	if (!cursor->resid) {
5359a17d Ilya Dryomov    2018-01-20  874  		BUG_ON(!cursor->last_piece);
5359a17d Ilya Dryomov    2018-01-20  875  		return false;   /* no more data */
5359a17d Ilya Dryomov    2018-01-20  876  	}
f38a5181 Kent Overstreet 2013-08-07  877  
5359a17d Ilya Dryomov    2018-01-20  878  	if (!bytes || (it->iter.bi_size && it->iter.bi_bvec_done))
6aaa4511 Alex Elder      2013-03-06  879  		return false;	/* more bytes to process in this segment */
6aaa4511 Alex Elder      2013-03-06  880  
5359a17d Ilya Dryomov    2018-01-20  881  	if (!it->iter.bi_size) {
5359a17d Ilya Dryomov    2018-01-20  882  		it->bio = it->bio->bi_next;
5359a17d Ilya Dryomov    2018-01-20  883  		it->iter = it->bio->bi_iter;
5359a17d Ilya Dryomov    2018-01-20  884  		if (cursor->resid < it->iter.bi_size)
5359a17d Ilya Dryomov    2018-01-20  885  			it->iter.bi_size = cursor->resid;
25aff7c5 Alex Elder      2013-03-11  886  	}
6aaa4511 Alex Elder      2013-03-06  887  
5359a17d Ilya Dryomov    2018-01-20  888  	BUG_ON(cursor->last_piece);
5359a17d Ilya Dryomov    2018-01-20  889  	BUG_ON(cursor->resid < bio_iter_len(it->bio, it->iter));
5359a17d Ilya Dryomov    2018-01-20 @890  	cursor->last_piece = cursor->resid == bio_iter_len(it->bio, it->iter);
6aaa4511 Alex Elder      2013-03-06  891  	return true;
6aaa4511 Alex Elder      2013-03-06  892  }
ea96571f Alex Elder      2013-04-05  893  #endif /* CONFIG_BLOCK */
df6ad1f9 Alex Elder      2012-06-11  894  

:::::: The code at line 890 was first introduced by commit
:::::: 5359a17d2706b86da2af83027343d5eb256f7670 libceph, rbd: new bio handling code (aka don't clone bios)

:::::: TO: Ilya Dryomov <idryomov@gmail.com>
:::::: CC: Ilya Dryomov <idryomov@gmail.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
