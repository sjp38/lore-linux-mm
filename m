Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5898E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 04:01:22 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q16so16998570ios.1
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 01:01:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 64sor14270554ioy.47.2019.01.04.01.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 01:01:21 -0800 (PST)
MIME-Version: 1.0
References: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
 <20181106140638.GN27423@dhcp22.suse.cz> <542cd3516b54d88d1bffede02c6045b8@codeaurora.org>
 <20181106200823.GT27423@dhcp22.suse.cz> <5e55c6e64a2bfd6eed855ea17a34788b@codeaurora.org>
 <40a4d5154fbd0006fbe55eb68703bb65@codeaurora.org> <20190104085801.GH31793@dhcp22.suse.cz>
In-Reply-To: <20190104085801.GH31793@dhcp22.suse.cz>
From: Arun Sudhilal <getarunks@gmail.com>
Date: Fri, 4 Jan 2019 14:31:09 +0530
Message-ID: <CABOM9ZpAEp_BMBcy-ywj0J33CNuMRwNeS9tUainOxRgPOndxfQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, "arunks.linux" <arunks.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 4, 2019 at 2:28 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 04-01-19 10:35:58, Arun KS wrote:
> > On 2018-11-07 11:51, Arun KS wrote:
> > > On 2018-11-07 01:38, Michal Hocko wrote:
> > > > On Tue 06-11-18 21:01:29, Arun KS wrote:
> > > > > On 2018-11-06 19:36, Michal Hocko wrote:
> > > > > > On Tue 06-11-18 11:33:13, Arun KS wrote:
> > > > > > > When free pages are done with higher order, time spend on
> > > > > > > coalescing pages by buddy allocator can be reduced. With
> > > > > > > section size of 256MB, hot add latency of a single section
> > > > > > > shows improvement from 50-60 ms to less than 1 ms, hence
> > > > > > > improving the hot add latency by 60%. Modify external
> > > > > > > providers of online callback to align with the change.
> > > > > > >
> > > > > > > This patch modifies totalram_pages, zone->managed_pages and
> > > > > > > totalhigh_pages outside managed_page_count_lock. A follow up
> > > > > > > series will be send to convert these variable to atomic to
> > > > > > > avoid readers potentially seeing a store tear.
> > > > > >
> > > > > > Is there any reason to rush this through rather than wait for counters
> > > > > > conversion first?
> > > > >
> > > > > Sure Michal.
> > > > >
> > > > > Conversion patch, https://patchwork.kernel.org/cover/10657217/
> > > > > is currently
> > > > > incremental to this patch.
> > > >
> > > > The ordering should be other way around. Because as things stand with
> > > > this patch first it is possible to introduce a subtle race prone
> > > > updates. As I've said I am skeptical the race would matter, really,
> > > > but
> > > > there is no real reason to risk for that. Especially when you have the
> > > > other (first) half ready.
> > >
> > > Makes sense. I have rebased the preparatory patch on top of -rc1.
> > > https://patchwork.kernel.org/patch/10670787/
> >
> > Hello Michal,
> >
> > Please review version 7 sent,
> > https://lore.kernel.org/patchwork/patch/1028908/
>
> I believe I have give my Acked-by to this version already, and v7 indeed
> has it. Are there any relevant changes since v6 for me to do the review
> again. If yes you should have dropped the Acked-by.

No Michal. Patch is same. Only difference is this patch is re-based on
top of preparatory patch.
https://patchwork.kernel.org/patch/10670787/

Regards,
Arun

> --
> Michal Hocko
> SUSE Labs
