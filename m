Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBF66B0069
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 20:18:00 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o74so299972iod.15
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 17:18:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d141sor3150149iod.175.2017.10.16.17.17.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 17:17:59 -0700 (PDT)
Date: Mon, 16 Oct 2017 17:17:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm: slabinfo: dump CONFIG_SLABINFO
In-Reply-To: <1507656303-103845-3-git-send-email-yang.s@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1710161717430.140151@chino.kir.corp.google.com>
References: <1507656303-103845-1-git-send-email-yang.s@alibaba-inc.com> <1507656303-103845-3-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Oct 2017, Yang Shi wrote:

> According to the discussion with Christoph [1], it sounds it is pointless
> to keep CONFIG_SLABINFO around.
> 
> This patch just remove CONFIG_SLABINFO config option, but /proc/slabinfo
> is still available.
> 
> [1] https://marc.info/?l=linux-kernel&m=150695909709711&w=2
> 
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>

Acked-by: David Rientjes <rientjes@google.com>

Cool!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
