Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8B3C6B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:21:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p1-v6so143202wrm.7
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:21:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23si3957489ede.31.2018.04.24.06.21.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 06:21:01 -0700 (PDT)
Date: Tue, 24 Apr 2018 07:20:57 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180424132057.GE17484@dhcp22.suse.cz>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz>
 <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu.ncepu@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Chunyu Hu <chuhu@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
[...]
> So if there is a new flag, it would be the 25th bits.

No new flags please. Can you simply store a simple bool into fail_page_alloc
and have save/restore api for that?

-- 
Michal Hocko
SUSE Labs
