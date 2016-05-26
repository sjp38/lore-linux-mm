Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 627CA6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 09:02:16 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so108571804pad.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 06:02:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o193si6546194pfo.226.2016.05.26.06.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 06:02:14 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: oh the joy of swap files
Date: Thu, 26 May 2016 15:02:03 +0200
Message-Id: <1464267724-31423-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: darrick.wong@oracle.com
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

Quirk out of ->bmap for reflink inodes because the swap code still
believes it's a good idea to blindly bypass the fs if it exists.

This is a bit of a crude hack, but without redesigning how swapfiles
work we can't really do very much better.  Except for a real error
code from ->bmap, but that's a bit like putting lipstick on a pig..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
