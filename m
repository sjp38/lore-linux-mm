Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4AE46B0069
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 05:32:26 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id v7so11515856uaf.5
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 02:32:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x6sor2673767uac.2.2017.10.23.02.32.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Oct 2017 02:32:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171023084911.glsz6sd22mq2ey2o@dhcp22.suse.cz>
References: <20171018063123.21983-1-bsingharora@gmail.com> <20171018063123.21983-2-bsingharora@gmail.com>
 <20171020130845.m5sodqlqktrcxkks@dhcp22.suse.cz> <CAKTCnzkdoC6aVKSkTS95+MyVLHbMaEiUXaAJUXSicmdCZPNCNw@mail.gmail.com>
 <20171023084911.glsz6sd22mq2ey2o@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 23 Oct 2017 20:32:25 +1100
Message-ID: <CAKTCnz=n3CFEhYb=WOENPB6ENrLoMg4_hRP2Tc70GLjc8aMVhg@mail.gmail.com>
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 23, 2017 at 7:49 PM, Michal Hocko <mhocko@suse.com> wrote:
> On Sat 21-10-17 08:55:59, Balbir Singh wrote:
>> On Sat, Oct 21, 2017 at 12:08 AM, Michal Hocko <mhocko@suse.com> wrote:
>> > On Wed 18-10-17 17:31:23, Balbir Singh wrote:
>> >> With HMM, we can have either public or private zone
>> >> device pages. With private zone device pages, they should
>> >> show up as swapped entities. For public zone device pages
>> >> the smaps output can be confusing and incomplete.
>> >>
>> >> This patch adds a new attribute to just smaps to show
>> >> device memory usage.
>> >
>> > As this will become user API which we will have to maintain for ever I
>> > would really like to hear about who is going to use this information and
>> > what for.
>>
>> This is something I observed when running some tests with HMM/CDM.
>> The issue I had was that there was no visibility of what happened to the
>> pages after the following sequence
>>
>> 1. malloc/mmap pages
>> 2. migrate_vma() to ZONE_DEVICE (hmm/cdm space)
>> 3. look at smaps
>>
>> If we look at smaps after 1 and the pages are faulted in we can see the
>> pages for the region, but at point 3, there is absolutely no visibility of
>> what happened to the pages. I thought smaps is a good way to provide
>> the visibility as most developers use that interface. It's more to fix the
>> inconsistency I saw w.r.t visibility and accounting.
>
> Yes I can see how this can be confusing. But, well, I have grown overly
> cautious regarding user APIs over time. So I would rather not add
> something new until we have a real user with a usecase in mind. We can
> always add this later but once we have exposed the accounting we are
> bound to maintain it for ever.

I see your point. But we are beginning to build on top of this. I'll just add
it as a private patch in my patchset. But soon, we'll need to address HMM/CDM
pages of different sizes as well. My problem right now is to ensure correctness
of the design and expectations and a large part of it is tracking
where the pages
are.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
