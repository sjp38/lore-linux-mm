Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id CF7CD6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 16:40:39 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so35786089pab.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 13:40:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uz5si37727829pac.230.2015.11.02.13.40.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 13:40:39 -0800 (PST)
Date: Mon, 2 Nov 2015 13:40:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas
 with holes
Message-Id: <20151102134038.7a326c583375364ece570173@linux-foundation.org>
In-Reply-To: <56379FC2.8000803@oracle.com>
References: <007901d1139a$030b0440$09210cc0$@alibaba-inc.com>
	<56350014.2040800@oracle.com>
	<013501d11519$2e5e6940$8b1b3bc0$@alibaba-inc.com>
	<56379FC2.8000803@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Hugh Dickins' <hughd@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Davidlohr Bueso' <dave@stgolabs.net>

On Mon, 2 Nov 2015 09:39:14 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> On 11/01/2015 06:50 PM, Hillf Danton wrote:
> > Andrew, please correct me if I miss/mess anything.
> >  
> >>> This hunk is already in the next tree, see below please.
> >>>
> >>
> >> Ah, the whole series to add shmem like code to handle hole punch/fault
> >> races is in the next tree.  It has been determined that most of this
> >> series is not necessary.  For the next tree, ideally the following
> >> should happen:
> >> - revert the series
> >> 	0830d5afd4ab69d01cf5ceba9b9f2796564c4eb6
> >> 	4e0a78fea078af972276c2d3aeaceb2bac80e033
> >> 	251c8a023a0c639725e014a612e8c05a631ce839
> >> 	03bcef375766af4db12ec783241ac39f8bf5e2b1
> >> - Add this patch (if Ack'ed/reviewed) to fix remove_inode_hugepages
> >> - Add a new patch for the handle hole punch/fault race.  It modifies
> >>   same code as this patch, so I have not sent out until this is Ack'ed.
> >>
> >> I will admit that I do not fully understand how maintainers manage their
> >> trees and share patches.  If someone can make suggestions on how to handle
> >> this situation (create patches against what tree? send patches to who?),
> >> I will be happy to make it happen.
> >>
> > The rule is to prepare patches against the next tree and deliver patches to
> > linux-mm with AKPM, linux-kernel cced. The authors and maintainers of the
> > current code your patches change should also be cced.
> > And those guys you want to get ack and comments.
> > 
> > In this case, you should first ask Andrew to withdraw the 4 commits.
> > Then send your new patches, one after another, one problem a patch.
> > 
> > Best Wishes
> > Hillf
> 
> Andrew,
> 
> As mentioned above, it has been determined that most of the series titled
> "[PATCH v2 0/4] hugetlbfs fallocate hole punch race with page faults" is
> unnecessary.  Ideally, we want to remove this entire series from mmotm and
> linux-next.  It  will be replaced with a simpler patch.

I dropped them all.

> However, before that happens I would like to address bugs in the current
> code as pointed out by Hugh Dickins.  These are addresses in the patch
> which started this thread:
> "[PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas with holes"

And merged that.  With a note reminding myself to get a Hugh ack ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
