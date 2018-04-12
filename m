Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 064AB6B0003
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 04:21:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id h12-v6so3252809pls.23
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 01:21:22 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d32-v6si2900414pld.678.2018.04.12.01.21.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 01:21:22 -0700 (PDT)
Date: Thu, 12 Apr 2018 10:21:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
Message-ID: <20180412082118.GT23400@dhcp22.suse.cz>
References: <20180411120452.1736-1-mhocko@kernel.org>
 <97504dda-4252-a150-e7b5-43fe587aa055@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97504dda-4252-a150-e7b5-43fe587aa055@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Thu 12-04-18 10:04:06, Michael Kerrisk wrote:
> Hello Michal,
> 
> On 04/11/2018 02:04 PM, mhocko@kernel.org wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
> > atomicaly probe for a given address range.
> > 
> > [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks! I've applied your patch, and done a little tweaking. The results
> have already been pushed.

Thanks!
-- 
Michal Hocko
SUSE Labs
