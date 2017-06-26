Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 507896B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 12:43:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v60so29233657wrc.7
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 09:43:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si183490wmm.190.2017.06.26.09.43.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 09:43:56 -0700 (PDT)
Date: Mon, 26 Jun 2017 18:42:45 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v2 00/51] block: support multipage bvec
Message-ID: <20170626164245.GO2866@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20170626121034.3051-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 26, 2017 at 08:09:43PM +0800, Ming Lei wrote:
>   btrfs: avoid access to .bi_vcnt directly
>   btrfs: avoid to access bvec table directly for a cloned bio
>   btrfs: comment on direct access bvec table
>   btrfs: use bvec_get_last_page to get bio's last page
>   fs/btrfs: convert to bio_for_each_segment_all_sp()

Acked-by: David Sterba <dsterba@suse.com>

for all the btrfs patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
