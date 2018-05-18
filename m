Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D51646B0646
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:03:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r23-v6so5954060wrc.2
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:03:28 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z16-v6si6873312wrc.443.2018.05.18.10.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 10:03:27 -0700 (PDT)
Date: Fri, 18 May 2018 19:08:12 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: do we still need ->is_dirty_writeback
Message-ID: <20180518170812.GA5190@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org

Hi Mel,

you added the is_dirty_writeback callback a couple years ago mostly
to work around the crazy ext3 writeback code, which is long gone now.
We still use buffer_check_dirty_writeback on the block device, but
without that ext3 case we really should not need it anymore.

That leaves NFS, where I don't understand why it doesn't simply
use PageWrite?
