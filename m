Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 202536B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 07:38:22 -0400 (EDT)
Received: by wiun10 with SMTP id n10so62288628wiu.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 04:38:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si23213338wiy.1.2015.04.29.04.38.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 04:38:20 -0700 (PDT)
Date: Wed, 29 Apr 2015 13:38:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC PATCH] mmap.2: clarify MAP_LOCKED semantic (was: Re: Should
 mmap MAP_LOCKED fail if mm_poppulate fails?)
Message-ID: <20150429113818.GC16097@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
 <20150428164302.GI2659@dhcp22.suse.cz>
 <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
 <20150428183535.GB30918@dhcp22.suse.cz>
 <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 28-04-15 11:38:35, Linus Torvalds wrote:
> On Tue, Apr 28, 2015 at 11:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >
> > I am still not sure I see the problem here.
> 
> Basically, I absolutely hate the notion of us doing something
> unsynchronized, when I can see us undoing a mmap that another thread
> is doing. It's wrong.

OK, I have checked the mmap(2) man page and there is no single mention
about multi-threaded usage. So even though I personally think that
user fault handlers which do mmap(MAP_FIXED) without synchronization
to parallel mmaps are broken by definition we cannot simply rule them
out and it is not the kernel job to make them broken even more or in a
subtly different way.
So here is an RFC for the man page patch. I am not very good in the
format but man doesn't complain about any formating issues.
---
