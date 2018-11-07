Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3A96B04EE
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:28:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x98-v6so9288361ede.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:28:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6-v6si283331ejd.9.2018.11.07.02.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 02:28:39 -0800 (PST)
Date: Wed, 7 Nov 2018 11:28:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
Message-ID: <20181107102837.GC27423@dhcp22.suse.cz>
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
 <63d9f48c-e39f-d345-0fb6-2f04afe769a2@yandex-team.ru>
 <08a61c003eed0280fd82f6200debcbca@codeaurora.org>
 <10c88df6-dbb1-7490-628c-055d59b5ad8e@yandex-team.ru>
 <22fa2222012341a54f6b0b6aea341aa2@codeaurora.org>
 <c3b0edf9-e6a2-c1ab-8490-d94b9830c8ae@yandex-team.ru>
 <89a259aa-156e-041c-b3bc-266824acb173@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89a259aa-156e-041c-b3bc-266824acb173@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Arun KS <arunks@codeaurora.org>, keescook@chromium.org, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, julia.lawall@lip6.fr

On Wed 07-11-18 09:50:10, Vlastimil Babka wrote:
> On 11/7/18 8:02 AM, Konstantin Khlebnikov wrote:
[...]
> > Could you point what exactly are you fixing with this set?
> > 
> > from v2:
> > 
> >  > totalram_pages, zone->managed_pages and totalhigh_pages updates
> >  > are protected by managed_page_count_lock, but readers never care
> >  > about it. Convert these variables to atomic to avoid readers
> >  > potentially seeing a store tear.
> > 
> > This?
> > 
> > 
> > Aligned unsigned long almost always stored at once.
> 
> The point is "almost always", so better not rely on it :) But the main
> motivation was that managed_page_count_lock handling was complicating
> Arun's "memory_hotplug: Free pages as higher order" patch and it seemed
> a better idea to just remove and convert this to atomics, with
> preventing potential store-to-read tearing as a bonus.

And more importantly the lock itself seems bogus as mentioned here
http://lkml.kernel.org/r/20181106141732.GR27423@dhcp22.suse.cz

> It would be nice to mention it in the changelogs though.

agreed
-- 
Michal Hocko
SUSE Labs
