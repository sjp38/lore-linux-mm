Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0AC76B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 17:56:00 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id d12so7109932uaj.18
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:56:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h123sor829175vka.272.2017.10.20.14.56.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 14:56:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020130845.m5sodqlqktrcxkks@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com> <20171018063123.21983-2-bsingharora@gmail.com>
 <20171020130845.m5sodqlqktrcxkks@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 21 Oct 2017 08:55:59 +1100
Message-ID: <CAKTCnzkdoC6aVKSkTS95+MyVLHbMaEiUXaAJUXSicmdCZPNCNw@mail.gmail.com>
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>

On Sat, Oct 21, 2017 at 12:08 AM, Michal Hocko <mhocko@suse.com> wrote:
> On Wed 18-10-17 17:31:23, Balbir Singh wrote:
>> With HMM, we can have either public or private zone
>> device pages. With private zone device pages, they should
>> show up as swapped entities. For public zone device pages
>> the smaps output can be confusing and incomplete.
>>
>> This patch adds a new attribute to just smaps to show
>> device memory usage.
>
> As this will become user API which we will have to maintain for ever I
> would really like to hear about who is going to use this information and
> what for.

This is something I observed when running some tests with HMM/CDM.
The issue I had was that there was no visibility of what happened to the
pages after the following sequence

1. malloc/mmap pages
2. migrate_vma() to ZONE_DEVICE (hmm/cdm space)
3. look at smaps

If we look at smaps after 1 and the pages are faulted in we can see the
pages for the region, but at point 3, there is absolutely no visibility of
what happened to the pages. I thought smaps is a good way to provide
the visibility as most developers use that interface. It's more to fix the
inconsistency I saw w.r.t visibility and accounting.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
