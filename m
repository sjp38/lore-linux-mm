Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFB96B027C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:40:44 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so36238206wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:40:44 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id hd4si7510165wjb.149.2016.12.16.07.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:40:43 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id xy5so15102111wjc.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:40:43 -0800 (PST)
Date: Fri, 16 Dec 2016 16:40:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/9 v2] xfs: introduce and use KM_NOLOCKDEP to silence
 reclaim lockdep false positives
Message-ID: <20161216154041.GA7645@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215140715.12732-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

Updated patch after Mike noticed a BUG_ON when KM_NOLOCKDEP is used.
---
