Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A16B76B06EA
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 06:15:34 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c7so1129657qkg.16
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 03:15:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p11si52584qtn.50.2018.11.09.03.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 03:15:33 -0800 (PST)
Date: Fri, 9 Nov 2018 19:15:09 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V7 10/24] block: introduce multipage page bvec helpers
Message-ID: <20181109111508.GA11290@ming.t460p>
References: <20180627124548.3456-11-ming.lei@redhat.com>
 <201806272319.0p98i2TZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201806272319.0p98i2TZ%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 27, 2018 at 11:59:37PM +0800, kbuild test robot wrote:
> Hi Ming,
> 
> Thank you for the patch! Perhaps something to improve:
> 
> [auto build test WARNING on linus/master]
> [also build test WARNING on v4.18-rc2]
> [cannot apply to next-20180627]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Ming-Lei/block-support-multipage-bvec/20180627-214022
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>    net/ceph/messenger.c:842:25: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:842:25: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:847:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:848:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:855:29: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:869:9: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:139:37: sparse: expression using sizeof(void)
>    include/linux/bvec.h:140:32: sparse: expression using sizeof(void)
>    include/linux/bvec.h:140:32: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:889:9: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
>    net/ceph/messenger.c:890:47: sparse: expression using sizeof(void)
> >> net/ceph/messenger.c:890:47: sparse: too many warnings
> 
> vim +890 net/ceph/messenger.c
> 
> 6aaa4511 Alex Elder      2013-03-06  862  
> 8ae4f4f5 Alex Elder      2013-03-14  863  static bool ceph_msg_data_bio_advance(struct ceph_msg_data_cursor *cursor,
> 8ae4f4f5 Alex Elder      2013-03-14  864  					size_t bytes)
> 6aaa4511 Alex Elder      2013-03-06  865  {
> 5359a17d Ilya Dryomov    2018-01-20  866  	struct ceph_bio_iter *it = &cursor->bio_iter;
> 6aaa4511 Alex Elder      2013-03-06  867  
> 5359a17d Ilya Dryomov    2018-01-20  868  	BUG_ON(bytes > cursor->resid);
> 5359a17d Ilya Dryomov    2018-01-20  869  	BUG_ON(bytes > bio_iter_len(it->bio, it->iter));
> 25aff7c5 Alex Elder      2013-03-11  870  	cursor->resid -= bytes;
> 5359a17d Ilya Dryomov    2018-01-20  871  	bio_advance_iter(it->bio, &it->iter, bytes);
> f38a5181 Kent Overstreet 2013-08-07  872  
> 5359a17d Ilya Dryomov    2018-01-20  873  	if (!cursor->resid) {
> 5359a17d Ilya Dryomov    2018-01-20  874  		BUG_ON(!cursor->last_piece);
> 5359a17d Ilya Dryomov    2018-01-20  875  		return false;   /* no more data */
> 5359a17d Ilya Dryomov    2018-01-20  876  	}
> f38a5181 Kent Overstreet 2013-08-07  877  
> 5359a17d Ilya Dryomov    2018-01-20  878  	if (!bytes || (it->iter.bi_size && it->iter.bi_bvec_done))
> 6aaa4511 Alex Elder      2013-03-06  879  		return false;	/* more bytes to process in this segment */
> 6aaa4511 Alex Elder      2013-03-06  880  
> 5359a17d Ilya Dryomov    2018-01-20  881  	if (!it->iter.bi_size) {
> 5359a17d Ilya Dryomov    2018-01-20  882  		it->bio = it->bio->bi_next;
> 5359a17d Ilya Dryomov    2018-01-20  883  		it->iter = it->bio->bi_iter;
> 5359a17d Ilya Dryomov    2018-01-20  884  		if (cursor->resid < it->iter.bi_size)
> 5359a17d Ilya Dryomov    2018-01-20  885  			it->iter.bi_size = cursor->resid;
> 25aff7c5 Alex Elder      2013-03-11  886  	}
> 6aaa4511 Alex Elder      2013-03-06  887  
> 5359a17d Ilya Dryomov    2018-01-20  888  	BUG_ON(cursor->last_piece);
> 5359a17d Ilya Dryomov    2018-01-20  889  	BUG_ON(cursor->resid < bio_iter_len(it->bio, it->iter));
> 5359a17d Ilya Dryomov    2018-01-20 @890  	cursor->last_piece = cursor->resid == bio_iter_len(it->bio, it->iter);
> 6aaa4511 Alex Elder      2013-03-06  891  	return true;
> 6aaa4511 Alex Elder      2013-03-06  892  }
> ea96571f Alex Elder      2013-04-05  893  #endif /* CONFIG_BLOCK */
> df6ad1f9 Alex Elder      2012-06-11  894  
> 
> :::::: The code at line 890 was first introduced by commit
> :::::: 5359a17d2706b86da2af83027343d5eb256f7670 libceph, rbd: new bio handling code (aka don't clone bios)
> 
> :::::: TO: Ilya Dryomov <idryomov@gmail.com>
> :::::: CC: Ilya Dryomov <idryomov@gmail.com>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Actually this sparse warning on bio_iter_len() can be triggered without this patch
too. This patch changes code in bvec.h, just causes the warned line changed. 


thanks,
Ming
