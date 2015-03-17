Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3046C900016
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:57:09 -0400 (EDT)
Received: by wixw10 with SMTP id w10so45598724wix.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:57:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez12si2146869wid.0.2015.03.17.04.56.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 04:56:59 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/9 v2] Helper to abstract vma handling in media layer
Date: Tue, 17 Mar 2015 12:56:30 +0100
Message-Id: <1426593399-6549-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-media@vger.kernel.org
Cc: Hans Verkuil <hans.verkuil@cisco.com>, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Jan Kara <jack@suse.cz>

  Hello,

  After a long pause I'm sending second version of my patch series to abstract
vma handling from the various media drivers. After this patch set drivers have
to know much less details about vmas, their types, and locking. My motivation
for the series is that I want to change get_user_pages() locking and I want to
handle subtle locking details in as few places as possible.

The core of the series is the new helper get_vaddr_pfns() which is given a
virtual address and it fills in PFNs into provided array. If PFNs correspond to
normal pages it also grabs references to these pages. The difference from
get_user_pages() is that this function can also deal with pfnmap, mixed, and io
mappings which is what the media drivers need.

I have tested the patches with vivid driver so at least vb2 code got some
exposure. Conversion of other drivers was just compile-tested so I'd like to
ask respective maintainers if they could have a look.  Also I'd like to ask mm
folks to check patch 2/9 implementing the helper. Thanks!

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
