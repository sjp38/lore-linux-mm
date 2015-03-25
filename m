Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6E25C6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:26:32 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so28606640pdb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:26:32 -0700 (PDT)
Received: from tama50.ecl.ntt.co.jp (tama50.ecl.ntt.co.jp. [129.60.39.147])
        by mx.google.com with ESMTP id pw8si3723988pbc.60.2015.03.25.06.26.30
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 06:26:31 -0700 (PDT)
Message-ID: <5512B781.1070607@lab.ntt.co.jp>
Date: Wed, 25 Mar 2015 22:26:25 +0900
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
MIME-Version: 1.0
Subject: Re: [next:master 6096/6547] fs/nilfs2/btree.c:1611 nilfs_btree_seek_key()
 warn: impossible condition '(start > (~0)) => (0-u64max > u64max)'
References: <20150324084823.GB16501@mwanda>
In-Reply-To: <20150324084823.GB16501@mwanda>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kbuild@01.org, Linux Memory Management List <linux-mm@kvack.org>

Hi,

On 2015/03/24 17:48, Dan Carpenter wrote:
> [ I suppose this is intentional but this is the first time
>    NILFS_BTREE_KEY_MAX has been used since it was introduced in 2009 so
>    it's strange. - dan ]
>
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   50d4d7167355e3ffa6e0a759e88cd277e58a5cb9
> commit: 6c302a8684cd06a7ec985fb23f31fa8f3f210eef [6096/6547] nilfs2: add bmap function to seek a valid key
>
> fs/nilfs2/btree.c:1611 nilfs_btree_seek_key() warn: impossible condition '(start > (~0)) => (0-u64max > u64max)'
>
<snip>
> 6c302a86 Ryusuke Konishi 2015-03-20  1604  static int nilfs_btree_seek_key(const struct nilfs_bmap *btree, __u64 start,
> 6c302a86 Ryusuke Konishi 2015-03-20  1605  				__u64 *keyp)
> 6c302a86 Ryusuke Konishi 2015-03-20  1606  {
> 6c302a86 Ryusuke Konishi 2015-03-20  1607  	struct nilfs_btree_path *path;
> 6c302a86 Ryusuke Konishi 2015-03-20  1608  	const int minlevel = NILFS_BTREE_LEVEL_NODE_MIN;
> 6c302a86 Ryusuke Konishi 2015-03-20  1609  	int ret;
> 6c302a86 Ryusuke Konishi 2015-03-20  1610
> 6c302a86 Ryusuke Konishi 2015-03-20 @1611  	if (start > NILFS_BTREE_KEY_MAX)
> 6c302a86 Ryusuke Konishi 2015-03-20  1612  		return -ENOENT;

Thanks.  This check is actually meaningless.
Will fix it.

Regards,
Ryusuke Konishi


> 6c302a86 Ryusuke Konishi 2015-03-20  1613
> 6c302a86 Ryusuke Konishi 2015-03-20  1614  	path = nilfs_btree_alloc_path();
> 6c302a86 Ryusuke Konishi 2015-03-20  1615  	if (!path)
> 6c302a86 Ryusuke Konishi 2015-03-20  1616  		return -ENOMEM;
> 6c302a86 Ryusuke Konishi 2015-03-20  1617
> 6c302a86 Ryusuke Konishi 2015-03-20  1618  	ret = nilfs_btree_do_lookup(btree, path, start, NULL, minlevel, 0);
> 6c302a86 Ryusuke Konishi 2015-03-20  1619  	if (!ret)
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
