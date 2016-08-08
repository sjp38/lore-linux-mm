Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D67AB6B0253
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 17:20:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d65so314423584ith.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 14:20:51 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id j190si2629340oih.206.2016.08.08.14.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 14:20:51 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id c15so31239702oig.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 14:20:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1470686593-31943-1-git-send-email-vdavydov@virtuozzo.com>
References: <20160808183754.GE1983@esperanza> <1470686593-31943-1-git-send-email-vdavydov@virtuozzo.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 8 Aug 2016 14:20:50 -0700
Message-ID: <CA+55aFxuF8yOZLD=EWuT6dOkEnzEAa34s7MVtm9eZ=EzyZWtWg@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: only mark charged pages with PageKmemcg
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 8, 2016 at 1:03 PM, Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> To distinguish non-slab pages charged to kmemcg we mark them PageKmemcg [..]

Eric, can you confirm that this fixes your issue?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
