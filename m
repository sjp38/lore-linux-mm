Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD5C76B0253
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 04:37:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c137so29242337pga.6
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 01:37:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p13si2179691pll.319.2017.10.05.01.37.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 01:37:01 -0700 (PDT)
Date: Thu, 5 Oct 2017 10:36:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Why is NFS using a_ops->freepage?
Message-ID: <20171005083657.GA28132@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nfs@vger.kernel.org, linux-mm@kvack.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>

Hello,

I'm doing some work in page cache handling and I have noticed that NFS is
the only user of mapping->a_ops->freepage callback. From a quick look I
don't see why isn't NFS using ->releasepage / ->invalidatepage callback as
all other filesystems do? I agree you would have to set PagePrivate bit for
those to get called for the directory mapping however that would seem like
a cleaner thing to do anyway - in fact you do have private data in the
page.  Just they are not pointed to by page->private but instead are stored
as page data... Am I missing something?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
