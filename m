Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1B4506B0055
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 08:59:31 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id y1so3578327lam.20
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:31 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id v4si10179154laj.97.2014.03.24.05.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 05:59:29 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so3574026lbg.21
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 05:59:28 -0700 (PDT)
Message-Id: <20140324122838.490106581@openvz.org>
Date: Mon, 24 Mar 2014 16:28:38 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 0/4] mm: A few memory tracker fixes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com, xemul@parallels.com, akpm@linux-foundation.org, gorcunov@openvz.org

Hi! Here is a few fixes for memory softdirty tracker inspired by
LKML thread https://lkml.org/lkml/2014/3/18/709 . It turned out
that indeed I've missed to setup softdirty bit on file mappings
in a few places. But it seems the only intensive user of this
feature is the criu tool where we dump/restore shared memory
areas completely regardless the softdirty bit status and
shared file mapped areas are not dumped at all so I'm not
sure if the patches are stable material. Please take a look,
thanks.

	Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
