Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93F706B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:28:56 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id j10so27877386wjb.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:28:56 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id ks1si60395068wjb.237.2016.11.29.09.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:28:55 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id kp2so19058603wjc.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:28:55 -0800 (PST)
Date: Tue, 29 Nov 2016 18:28:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161129172854.GF9796@dhcp22.suse.cz>
References: <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
 <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz>
 <20161129163807.GB19454@htj.duckdns.org>
 <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz>
 <20161129171333.GE9796@dhcp22.suse.cz>
 <CA+55aFw4R7B8pAJ4TNVefdtCVAnZKY28i6_+5jQhoop60-NuQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw4R7B8pAJ4TNVefdtCVAnZKY28i6_+5jQhoop60-NuQQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue 29-11-16 09:17:37, Linus Torvalds wrote:
> On Tue, Nov 29, 2016 at 9:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > How does this look like?
> 
> No.
> 
> I *really* want people to write out that "I am ok with the allocation failing".
> 
> It's not an "inconvenience". It's a sign that you are competent and
> that you know it will fail, and that you can handle it.
> 
> If you don't show that you know that, we warn about it.

How does this warning help those who are watching the logs? What are
they supposed to do about it? Unlike GFP_ATOMIC there is no tuning you
can possibly do.

>From my experience people tend to report those and worry about them
(quite often confusing them with the real OOM) and we usually only can
explain that this is nothing to worry about... And so then we sprinkle
GFP_NOWARN all over the place as we hit those. Is this really what we
want?

> And no, "GFP_NOWAIT" does *not* mean "I have a good fallback".

I am confused, how can anybody _rely_ on GFP_NOWAIT to succeed?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
