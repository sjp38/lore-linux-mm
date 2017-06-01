Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60D586B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 08:05:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so9500943wmc.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 05:05:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si7044533wrc.69.2017.06.01.05.05.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 05:05:58 -0700 (PDT)
Date: Thu, 1 Jun 2017 14:05:56 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [Cluster-devel] [PATCH 00/35 v1] pagevec API cleanups
Message-ID: <20170601120556.GD23077@quack2.suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
 <20170601113604.GA10829@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601113604.GA10829@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, cluster-devel@redhat.com, linux-nilfs@vger.kernel.org, tytso@mit.edu, linux-xfs@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hugh Dickins <hughd@google.com>, linux-f2fs-devel@lists.sourceforge.net, David Howells <dhowells@redhat.com>, David Sterba <dsterba@suse.com>, ceph-devel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org

On Thu 01-06-17 04:36:04, Christoph Hellwig wrote:
> On Thu, Jun 01, 2017 at 11:32:10AM +0200, Jan Kara wrote:
> > * Implement ranged variants for pagevec_lookup and find_get_ functions. Lot
> >   of callers actually want a ranged lookup and we unnecessarily opencode this
> >   in lot of them.
> 
> How does this compare to Kents page cache iterators:
> 
> http://www.spinics.net/lists/linux-mm/msg104737.html

Interesting. I didn't know about that work. I guess the tradeoff is pretty
obvious - my patches are more conservative (changing less) and as a result
the API is not as neat as Kent's one. That being said I was also thinking
about something similar to what Kent did but what I didn't like about such
iterator is that you still need to specially handle the cases where you
break out of the loop (you need to do that with pagevecs too but there it
is kind of obvious from the API).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
