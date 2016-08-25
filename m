Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id F16FE83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 10:59:51 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so88999465ywb.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 07:59:51 -0700 (PDT)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id r3si10588414qkc.252.2016.08.25.07.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 07:59:51 -0700 (PDT)
Received: by mail-qk0-f171.google.com with SMTP id v123so48142455qkh.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 07:59:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160803152409.GB8962@t510>
References: <1469457565-22693-1-git-send-email-kwalker@redhat.com>
 <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org> <20160803152409.GB8962@t510>
From: Kyle Walker <kwalker@redhat.com>
Date: Thu, 25 Aug 2016 10:59:45 -0400
Message-ID: <CAEPKNT+0F=py9Zvg6f1BpJTAeeQJ4a8maiyY9cagQh7ouacehw@mail.gmail.com>
Subject: Re: [PATCH] mm: Move readahead limit outside of readahead, and
 advisory syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Geliang Tang <geliangtang@163.com>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <klamm@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Aug 3, 2016 at 11:24 AM, Rafael Aquini <aquini@redhat.com> wrote:
> IIRC one of the issues Linus had with previous attempts was because
> they were utilizing/bringing back a node-memory state based heuristic.
>
> Since Kyle patch is using a global state counter for that matter,
> I think that issue condition might now be sorted out.

It's been a few weeks since the last feedback. Are there any further
questions or concerns I can help out with?

--
Kyle Walker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
