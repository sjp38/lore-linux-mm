Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7332B6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:20:41 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id m12-v6so17709999ita.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:20:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n25-v6sor8487121ioc.99.2018.05.21.15.20.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 15:20:40 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
In-Reply-To: <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 15:20:29 -0700
Message-ID: <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 3:12 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/21/2018 03:07 PM, Daniel Colascione wrote:
> > Now let's return to max_map_count itself: what is it supposed to
achieve?
> > If we want to limit application kernel memory resource consumption,
let's
> > limit application kernel memory resource consumption, accounting for it
on
> > a byte basis the same way we account for other kernel objects allocated
on
> > behalf of userspace. Why should we have a separate cap just for the VMA
> > count?

> VMAs consume kernel memory and we can't reclaim them.  That's what it
> boils down to.

How is it different from memfd in that respect?
