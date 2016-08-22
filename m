Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF5D96B0260
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 13:35:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so208435394pfd.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 10:35:32 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 9si23626345pfr.240.2016.08.22.10.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 10:35:32 -0700 (PDT)
From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 0/3][V2] Provide accounting for dirty metadata
Date: Mon, 22 Aug 2016 13:34:59 -0400
Message-ID: <1471887302-12730-1-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, jack@suse.com, viro@zeniv.linux.org.uk, dchinner@redhat.com, hch@lst.de, linux-mm@kvack.org

Here is my updated set of patches for providing a way for fs'es to do their own
accounting for their dirty metadata pages.  The changes since V1 include

-Split the accounting + ->write_metadata patches out into their own patches.
-Added a few more account_metadata* helpers that I hadn't thought about
previously.
-Changed the bdi->sb_list to bdi->dirty_sb_list.  This is to avoid confusion
about the purpose of the list.  I do a splice of this list when processing it as
we have to drop the list lock and I didn't want to worry about umounts screwing
up the list while we were writing metadata.
-Added the dirty metadata counter to the various places we output those counters
(meminfo, oom messages, etc).

I've also actually changed btrfs to use these interfaces and have been testing
that code for almost a week now and have fixed up the various problems that
happend with V1 of this code.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
