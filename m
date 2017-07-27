Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C303F6B04AC
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 19:55:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so36827459wrc.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 16:55:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 123si11778778wmk.3.2017.07.27.16.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 16:55:43 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:55:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2][V3] slab and general reclaim improvements
Message-Id: <20170727165541.b9246aeb333227d7b36b5e8b@linux-foundation.org>
In-Reply-To: <1500576331-31214-1-git-send-email-jbacik@fb.com>
References: <1500576331-31214-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, kernel-team@fb.com

On Thu, 20 Jul 2017 14:45:29 -0400 josef@toxicpanda.com wrote:

> This is a new set of patches to address some slab reclaim issues I observed when
> trying to convert btrfs over to a purely slab meta data system.

Without more review-n-test I'm a bit reluctant to apply these even on a
see-how-it-goes basis.  Anyone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
