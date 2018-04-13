Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16E4C6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:05:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id g204-v6so5037431oic.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:05:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5-v6sor3073000ota.102.2018.04.13.09.05.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 09:05:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180413160435.GA17484@dhcp22.suse.cz>
References: <20180412153941.170849-1-jannh@google.com> <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
 <CAKgNAkgcJ2kCTff0=7=D3zPFwpJt-9EM8yis6-4qDjfvvb8ukw@mail.gmail.com>
 <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com>
 <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com> <CAG48ez085cASur3kZTRkdJY20dFZ4Yqc1KVOHxnCAn58_NtW8w@mail.gmail.com>
 <cfbbbe06-5e63-e43c-fb28-c5afef9e1e1d@nvidia.com> <9c714917-fc29-4d12-b5e8-cff28761a2c1@gmail.com>
 <20180413064917.GC17484@dhcp22.suse.cz> <CAG48ez2w+3FDh9LM3+P2EHowicjM2Xw6giR6uq=26JfWHYsTAQ@mail.gmail.com>
 <20180413160435.GA17484@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Fri, 13 Apr 2018 18:05:24 +0200
Message-ID: <CAG48ez3-xtmAt2EpRFR8GNKKPcsDsyg7XdwQ=D5w3Ym6w4Krjw@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, linux-man <linux-man@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Fri, Apr 13, 2018 at 6:04 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 13-04-18 17:04:09, Jann Horn wrote:
>> On Fri, Apr 13, 2018 at 8:49 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Fri 13-04-18 08:43:27, Michael Kerrisk wrote:
>> > [...]
>> >> So, you mean remove this entire paragraph:
>> >>
>> >>               For cases in which the specified memory region has not been
>> >>               reserved using an existing mapping,  newer  kernels  (Linux
>> >>               4.17  and later) provide an option MAP_FIXED_NOREPLACE that
>> >>               should be used instead; older kernels require the caller to
>> >>               use addr as a hint (without MAP_FIXED) and take appropriate
>> >>               action if the kernel places the new mapping at a  different
>> >>               address.
>> >>
>> >> It seems like some version of the first half of the paragraph is worth
>> >> keeping, though, so as to point the reader in the direction of a remedy.
>> >> How about replacing that text with the following:
>> >>
>> >>               Since  Linux 4.17, the MAP_FIXED_NOREPLACE flag can be used
>> >>               in a multithreaded program to avoid  the  hazard  described
>> >>               above.
>> >
>> > Yes, that sounds reasonable to me.
>>
>> But that kind of sounds as if you can't avoid it before Linux 4.17,
>> when actually, you just have to call mmap() with the address as hint,
>> and if mmap() returns a different address, munmap() it and go on your
>> normal error path.
>
> This is still racy in multithreaded application which is the main point
> of the whole section, no?

No, it isn't.
