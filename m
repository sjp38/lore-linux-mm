Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 574E96B026E
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 20:45:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b88-v6so274860pfj.4
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 17:45:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y12-v6si6603485pgg.158.2018.11.01.17.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 17:45:52 -0700 (PDT)
Date: Thu, 1 Nov 2018 20:45:50 -0400
From: Sasha Levin <sashal@kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20181102004550.GD194472@sasha-vm>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-team@fb.com" <kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
>Hi all,
>When debugging a memory leak issue (https://github.com/coreos/bugs/issues/2516)
>with v4.14.11-coreos, we noticed the same issue may have been fixed recently by
>Roman in the latest mainline (i.e. Linus's master branch) according to comment #7 of
>https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1792349, which lists these
>patches (I'm not sure if the 5-patch list is complete):
>
>010cb21d4ede math64: prevent double calculation of DIV64_U64_ROUND_UP() arguments
>f77d7a05670d mm: don't miss the last page because of round-off error
>d18bf0af683e mm: drain memcg stocks on css offlining
>71cd51b2e1ca mm: rework memcg kernel stack accounting
>f3a2fccbce15 mm: slowly shrink slabs with a relatively small number of objects
>
>Obviously at least some of the fixes are also needed in the longterm kernels like v4.14.y,
>but none of the 5 patches has the "Cc: stable@vger.kernel.org" tag? I'm wondering if
>these patches will be backported to the longterm kernels. BTW, the patches are not
>in v4.19, but I suppose they will be in v4.19.1-rc1?

There was an issue with this series:
https://lkml.org/lkml/2018/10/23/586, so it's waiting on a fix to be
properly tested.

--
Thanks,
Sasha
