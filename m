Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D61D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:58:11 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u13so35764591uau.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:58:11 -0700 (PDT)
Received: from mail-yb0-x241.google.com (mail-yb0-x241.google.com. [2607:f8b0:4002:c09::241])
        by mx.google.com with ESMTPS id u125si5696017ybb.292.2016.08.09.09.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 09:58:10 -0700 (PDT)
Received: by mail-yb0-x241.google.com with SMTP id g133so421186ybf.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:58:10 -0700 (PDT)
Message-ID: <1470761885.5324.7.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] mm: memcontrol: only mark charged pages with PageKmemcg
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Aug 2016 18:58:05 +0200
In-Reply-To: <CA+55aFxuF8yOZLD=EWuT6dOkEnzEAa34s7MVtm9eZ=EzyZWtWg@mail.gmail.com>
References: <20160808183754.GE1983@esperanza>
	 <1470686593-31943-1-git-send-email-vdavydov@virtuozzo.com>
	 <CA+55aFxuF8yOZLD=EWuT6dOkEnzEAa34s7MVtm9eZ=EzyZWtWg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 2016-08-08 at 14:20 -0700, Linus Torvalds wrote:
> On Mon, Aug 8, 2016 at 1:03 PM, Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> > To distinguish non-slab pages charged to kmemcg we mark them PageKmemcg [..]
> 
> Eric, can you confirm that this fixes your issue?
> 

It is fixing the issue for me, thanks a lot Vladimir and Linus.

(I also checked that commit 4949148ad433 was indeed the bug origin)

Tested-by: Eric Dumazet <edumazet@google.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
