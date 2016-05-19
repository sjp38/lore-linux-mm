Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6BE6B0260
	for <linux-mm@kvack.org>; Thu, 19 May 2016 04:20:14 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u185so123015365oie.3
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:20:14 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id t67si5656196oih.125.2016.05.19.01.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 01:20:13 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id t140so14825687oie.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:20:13 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 19 May 2016 10:20:13 +0200
Message-ID: <CAJfpeguD-S=CEogqcDOYAYJBzfyJG=MMKyFfpMo55bQk7d0_TQ@mail.gmail.com>
Subject: sharing page cache pages between multiple mappings
From: Miklos Szeredi <miklos@szeredi.hu>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org

Has anyone thought about sharing pages between multiple files?

The obvious application is for COW filesytems where there are
logically distinct files that physically share data and could easily
share the cache as well if there was infrastructure for it.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
