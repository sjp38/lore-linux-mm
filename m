Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 721256B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 09:35:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id a15-v6so3530364wrr.23
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 06:35:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13-v6si4380503edm.124.2018.06.06.06.35.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jun 2018 06:35:45 -0700 (PDT)
Date: Wed, 6 Jun 2018 15:35:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory mapped pages not being swapped out
Message-ID: <20180606133544.GG32433@dhcp22.suse.cz>
References: <CAJ6kbHezPzbLW=1mwdnywMn639X4eLz9nnRZdk6oeyLjXR6mQg@mail.gmail.com>
 <20180606124322.GB32498@dhcp22.suse.cz>
 <CAJ6kbHdz-UWL6dBdBZy9WFV6QBYqmMNEuUm+5s9LQok_RLDZfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ6kbHdz-UWL6dBdBZy9WFV6QBYqmMNEuUm+5s9LQok_RLDZfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Telles <rafaelt@simbioseventures.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed 06-06-18 10:28:00, Rafael Telles wrote:
> Thank you so much for your attention Michal,
> 
> Are there any settings (such as sysctl parameters) that I can use to better
> control the memory reclaiming? Such as: defining the max. amount of mmap
> pages allocated or max. amount of memory used by mmap pages?

None that I know of. You shouldn't really care about this, really.

> Or will the system start reclaiming only when it needs more memory?

Exactly. We try to keep the memory used as much as possible.

> I found that I could use madvise with MADV_DONTNEED in order to actively
> free RSS memory used by mmap pages, but it would add more complexity on my
> software.

That would be an option. But it really depends on what you are trying to
achieve.
-- 
Michal Hocko
SUSE Labs
