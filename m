Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA32928024C
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:58:31 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y6so24582050lff.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:58:31 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l5si29312713wjt.239.2016.09.20.13.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:58:28 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 0/4][V3] metadata throttling in writeback patches
Date: Tue, 20 Sep 2016 16:57:44 -0400
Message-ID: <1474405068-27841-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org, hannes@cmpxchg.org

This is the latest set of patches based on my conversations with Jan and
Johannes.  The biggest change has been changing the metadata accounting counters
to be in bytes intead of pages in order to better support varying blocksizes.
I've also stopped messing with the other pagecache related counters so we can
keep them truly separate.  Johannes suggested this change and I simply convert
the bytes counter to pages when calculating dirty limits and such.

The other big change is changing WB_WRITTEN/WB_DIRTIED to be in bytes instead of
pages as well.  This is just a name and accounting change, it doesn't really
change the core logic at all.

I'm sending this out ahead of my full battery of tests, but I want to get
feedback on this direction as soon as possible.  In the meantime I've changed my
btrfs specific patches to work with these patches and am running long running
tests now to verify everything still works.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
