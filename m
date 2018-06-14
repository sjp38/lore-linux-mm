Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEE6C6B000C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 21:24:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b6-v6so3361900qtp.18
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 18:24:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 22-v6si3954473qvl.182.2018.06.13.18.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 18:24:12 -0700 (PDT)
Date: Thu, 14 Jun 2018 09:23:54 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 11/30] block: implement bio_pages_all() via
 bio_for_each_segment_all()
Message-ID: <20180614012352.GC19828@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180609123014.8861-12-ming.lei@redhat.com>
 <20180613144412.GB4693@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180613144412.GB4693@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 07:44:12AM -0700, Christoph Hellwig wrote:
> Given that we have a single, dubious user of bio_pages_all I'd rather
> see it as an opencoded bio_for_each_ loop in the caller.

Yeah, that is fine since there is only one user in btrfs.

Thanks,
Ming
