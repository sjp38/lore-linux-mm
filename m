Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 693576B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:10:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y6-v6so275371wrm.10
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:10:12 -0700 (PDT)
Received: from lithops.sigma-star.at (lithops.sigma-star.at. [195.201.40.130])
        by mx.google.com with ESMTPS id x66si7296196wmg.226.2018.04.24.12.10.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 12:10:11 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: Re: vmalloc with GFP_NOFS
Date: Tue, 24 Apr 2018 21:10:08 +0200
Message-ID: <1912881.zKmfqiQKhD@blindfold>
In-Reply-To: <20180424162712.GL17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Steven Whitehouse <swhiteho@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Adrian Hunter <adrian.hunter@intel.com>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Mikulas Patocka <mpatocka@redhat.com>, linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org

[resending without html ...]

Am Dienstag, 24. April 2018, 18:27:12 CEST schrieb Michal Hocko:
> Hi,
> it seems that we still have few vmalloc users who perform GFP_NOFS
> allocation:
> drivers/mtd/ubi/io.c

UBI is not a big deal. We use it here like in UBIFS for debugging
when self-checks are enabled.

> fs/ext4/xattr.c
> fs/gfs2/dir.c
> fs/gfs2/quota.c
> fs/nfs/blocklayout/extent_tree.c
> fs/ubifs/debug.c
> fs/ubifs/lprops.c
> fs/ubifs/lpt_commit.c
> fs/ubifs/orphan.c

All users in UBIFS are debugging code and some error reporting.
No fast paths.
I think we can switch to prealloation + locking without much hassle.
I can prepare a patch.

Thanks,
//richard
