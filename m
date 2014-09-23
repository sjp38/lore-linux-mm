Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 73AA26B0039
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 11:03:38 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so3984356lbi.7
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 08:03:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si19051256lbf.54.2014.09.23.08.03.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 08:03:34 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2] Fix data corruption when blocksize < pagesize
Date: Tue, 23 Sep 2014 17:03:21 +0200
Message-Id: <1411484603-17756-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org, Ted Tso <tytso@mit.edu>


  Hello,

  these two patches fix the data corruption triggered by xfstests
generic/030 test for ext4. I believe XFS can use the same function to
deal with the problem... Dave can you verify? If the function is indeed
usable for XFS as well, through which tree are we going to merge it?
ext4 or xfs?

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
