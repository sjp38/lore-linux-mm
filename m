Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 503776B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:17:38 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j65so304787397iof.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:17:38 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id x190si2810864ite.81.2016.11.29.09.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:17:37 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id r94so30645334ioe.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:17:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129171333.GE9796@dhcp22.suse.cz>
References: <20161121215639.GF13371@merlins.org> <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz> <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz> <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz> <20161129163807.GB19454@htj.duckdns.org>
 <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz> <20161129171333.GE9796@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Nov 2016 09:17:37 -0800
Message-ID: <CA+55aFw4R7B8pAJ4TNVefdtCVAnZKY28i6_+5jQhoop60-NuQQ@mail.gmail.com>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue, Nov 29, 2016 at 9:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
> How does this look like?

No.

I *really* want people to write out that "I am ok with the allocation failing".

It's not an "inconvenience". It's a sign that you are competent and
that you know it will fail, and that you can handle it.

If you don't show that you know that, we warn about it.

And no, "GFP_NOWAIT" does *not* mean "I have a good fallback".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
