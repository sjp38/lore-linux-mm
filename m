Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF2326B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 22:33:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h29so73148152pfd.2
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:33:48 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id a90si2000639plc.969.2017.07.21.19.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 19:33:46 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id k72so2616574pfj.0
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:33:46 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 0/1] mm/hmm: Kconfig improvements for device memory and HMM interaction
Date: Fri, 21 Jul 2017 19:33:32 -0700
Message-Id: <20170722023333.6923-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi Jerome,

This applies on top of your hmm-next branch at
git://people.freedesktop.org/~glisse/linux.

Related point: even after this patch is applied, I'm still a bit unhappy
about another minor point, which is:

If you select CONFIG_ZONE_DEVICE and CONFIG_HMM_MIRROR, then
CONFIG_DEVICE_PRIVATE is still not selected. As I mentioned earlier,
this configures HMM in a way that is essentially useless. Therefore,
I'm still tempted to have CONFIG_HMM_MIRROR do an auto-select of
CONFIG_DEVICE_PRIVATE, or something like that.

Thoughts on that?

John Hubbard (1):
  mm/hmm: Kconfig improvements for device memory and HMM interaction

 mm/Kconfig | 52 ++++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 26 deletions(-)

-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
