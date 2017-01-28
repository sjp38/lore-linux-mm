Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 066536B0038
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 02:32:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so380953963pgf.3
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 23:32:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m11si6651343pln.99.2017.01.27.23.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 23:32:23 -0800 (PST)
Date: Fri, 27 Jan 2017 23:32:15 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Cluster-devel] [PATCH 8/8] Revert "ext4: fix wrong gfp type
 under transaction"
Message-ID: <20170128073215.GA19424@infradead.org>
References: <20170117155916.dcizr65bwa6behe7@thunk.org>
 <20170117161618.GT19699@dhcp22.suse.cz>
 <20170117172925.GA2486@quack2.suse.cz>
 <20170119083956.GE30786@dhcp22.suse.cz>
 <20170119092236.GC2565@quack2.suse.cz>
 <20170119094405.GK30786@dhcp22.suse.cz>
 <20170126074455.GC8456@dhcp22.suse.cz>
 <20170127061318.xd2qxashbl4dajez@thunk.org>
 <20170127093735.GB4143@dhcp22.suse.cz>
 <20170127164042.2o3bnyopihcb224g@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170127164042.2o3bnyopihcb224g@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 27, 2017 at 11:40:42AM -0500, Theodore Ts'o wrote:
> The reason why I'm nervous is that nojournal mode is not a common
> configuration, and "wait until production systems start failing" is
> not a strategy that I or many SRE-types find.... comforting.

What does SRE stand for?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
