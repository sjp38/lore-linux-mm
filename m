Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B9E086B00B2
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:44 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so2735751wiv.9
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si5967420wie.22.2014.03.17.12.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:43 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [RFC] Helper to abstract vma handling in media layer
Date: Mon, 17 Mar 2014 20:49:27 +0100
Message-Id: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

  Hello,

  The following patch series is my first stab at abstracting vma handling
from the various media drivers. After this patch set drivers have to know
much less details about vmas, their types, and locking. My motivation for
the series is that I want to change get_user_pages() locking and I want
to handle subtle locking details in as few places as possible.

The core of the series is the new helper get_vaddr_pfns() which is given a
virtual address and it fills in PFNs into provided array. If PFNs correspond to
normal pages it also grabs references to these pages. The difference from
get_user_pages() is that this function can also deal with pfnmap, mixed, and io
mappings which is what the media drivers need.

The patches are just compile tested (since I don't have any of the hardware
I'm afraid I won't be able to do any more testing anyway) so please handle
with care. I'm grateful for any comments.

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
