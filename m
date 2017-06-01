Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98AEF6B02F4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 07:36:08 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o12so32225460iod.15
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 04:36:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b31si3069202pli.250.2017.06.01.04.36.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 04:36:06 -0700 (PDT)
Date: Thu, 1 Jun 2017 04:36:04 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Cluster-devel] [PATCH 00/35 v1] pagevec API cleanups
Message-ID: <20170601113604.GA10829@infradead.org>
References: <20170601093245.29238-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, cluster-devel@redhat.com, linux-nilfs@vger.kernel.org, tytso@mit.edu, linux-xfs@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hugh Dickins <hughd@google.com>, linux-f2fs-devel@lists.sourceforge.net, David Howells <dhowells@redhat.com>, David Sterba <dsterba@suse.com>, ceph-devel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org

On Thu, Jun 01, 2017 at 11:32:10AM +0200, Jan Kara wrote:
> * Implement ranged variants for pagevec_lookup and find_get_ functions. Lot
>   of callers actually want a ranged lookup and we unnecessarily opencode this
>   in lot of them.

How does this compare to Kents page cache iterators:

http://www.spinics.net/lists/linux-mm/msg104737.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
