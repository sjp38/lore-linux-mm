Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 530076B029D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:24:52 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so157464847wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:24:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr6si22356476wic.42.2015.10.06.02.24.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:48 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 0/7] get_user_pages() cleanup
Date: Tue,  6 Oct 2015 11:24:23 +0200
Message-Id: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Jesper Nilsson <jesper.nilsson@axis.com>, linux-cris-kernel@axis.com, Mikael Starvik <starvik@axis.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Timur Tabi <timur@freescale.com>, linux-rdma@vger.kernel.org, Roland Dreier <roland@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, Andy Walls <awalls@md.metrocast.net>, linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>

From: Jan Kara <jack@suse.cz>

  Hello,

Now when the usage of get_user_pages() in media drivers got cleaned up, here
comes a series which removes knowledge about mmap_sem from a couple of other
drivers. Patches are trivial and standalone but please check, they are only
compile tested. If you are OK with them, either take them through your
respective trees or ack them and I can take care of pushing them to Linus
(probably through mm tree). Thanks.

After these patches there are some 12 call sites of get_user_pages() outside of
core code (mostly infiniband and RDMA). So we are slowly getting to the goal of
removing knowledge about page fault locking from drivers which will
consequently allow us to change the locking rules with reasonable effort.

								Honza

CC: Jesper Nilsson <jesper.nilsson@axis.com>
CC: linux-cris-kernel@axis.com
CC: Mikael Starvik <starvik@axis.com>
CC: linux-ia64@vger.kernel.org
CC: Tony Luck <tony.luck@intel.com>
CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
CC: Timur Tabi <timur@freescale.com>
CC: linux-rdma@vger.kernel.org
CC: Roland Dreier <roland@kernel.org>
CC: Daniel Vetter <daniel.vetter@intel.com>
CC: David Airlie <airlied@linux.ie>
CC: dri-devel@lists.freedesktop.org
CC: Andy Walls <awalls@md.metrocast.net>
CC: linux-media@vger.kernel.org
CC: Mauro Carvalho Chehab <mchehab@osg.samsung.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
