Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 370B282F85
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 21:50:26 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so8787393pab.0
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 18:50:26 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id a13si31209265pbu.165.2015.11.01.18.50.24
        for <linux-mm@kvack.org>;
        Sun, 01 Nov 2015 18:50:25 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <007901d1139a$030b0440$09210cc0$@alibaba-inc.com> <56350014.2040800@oracle.com>
In-Reply-To: <56350014.2040800@oracle.com>
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas with holes
Date: Mon, 02 Nov 2015 10:50:05 +0800
Message-ID: <013501d11519$2e5e6940$8b1b3bc0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Davidlohr Bueso' <dave@stgolabs.net>

Andrew, please correct me if I miss/mess anything.
 
> > This hunk is already in the next tree, see below please.
> >
> 
> Ah, the whole series to add shmem like code to handle hole punch/fault
> races is in the next tree.  It has been determined that most of this
> series is not necessary.  For the next tree, ideally the following
> should happen:
> - revert the series
> 	0830d5afd4ab69d01cf5ceba9b9f2796564c4eb6
> 	4e0a78fea078af972276c2d3aeaceb2bac80e033
> 	251c8a023a0c639725e014a612e8c05a631ce839
> 	03bcef375766af4db12ec783241ac39f8bf5e2b1
> - Add this patch (if Ack'ed/reviewed) to fix remove_inode_hugepages
> - Add a new patch for the handle hole punch/fault race.  It modifies
>   same code as this patch, so I have not sent out until this is Ack'ed.
> 
> I will admit that I do not fully understand how maintainers manage their
> trees and share patches.  If someone can make suggestions on how to handle
> this situation (create patches against what tree? send patches to who?),
> I will be happy to make it happen.
> 
The rule is to prepare patches against the next tree and deliver patches to
linux-mm with AKPM, linux-kernel cced. The authors and maintainers of the
current code your patches change should also be cced.
And those guys you want to get ack and comments.

In this case, you should first ask Andrew to withdraw the 4 commits.
Then send your new patches, one after another, one problem a patch.

Best Wishes
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
