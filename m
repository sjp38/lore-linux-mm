Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 799F66B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 06:59:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z129so6549059wmb.23
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:59:33 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id r20si29645757wra.91.2017.04.25.03.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 03:59:31 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id d79so24085829wmi.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:59:31 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20170425080047.GA16770@rapoport-lnx>
References: <487b2c79-f99b-6d0f-2412-aa75cde65569@gmail.com>
 <9af29fc6-dce2-f729-0f07-a0bfcc6c3587@gmail.com> <20170322135423.GB27789@rapoport-lnx>
 <e8c5ca4a-0710-7206-b96e-10d171bda218@gmail.com> <20170421110714.GC20569@rapoport-lnx>
 <4c05c2bb-af77-d706-9455-8ceaa5510580@gmail.com> <20170425080047.GA16770@rapoport-lnx>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 25 Apr 2017 12:59:11 +0200
Message-ID: <CAKgNAkjWPgBtSay0B9V8dD1cEax=0Yk+vZjRrGyfgB-BgQpbvQ@mail.gmail.com>
Subject: Re: Review request: draft ioctl_userfaultfd(2) manual page
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-man <linux-man@vger.kernel.org>

Hi Mike,

On 25 April 2017 at 10:00, Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> Hello Michael,
>
> On Fri, Apr 21, 2017 at 01:41:18PM +0200, Michael Kerrisk (man-pages) wrote:
>> Hi Mike,
>>
>
> [...]
>
>> >
>> > Yes.
>> > Just the future is only a week or two from today as we are at 4.11-rc7 :)
>>
>> Yes, I understand :-). So of course there's a *lot* more
>> new stuff to document, right?
>
> I've started to add the description of the new functionality to both
> userfaultfd.2 and ioctl_userfaultfd.2

Thanks for doing this!

> and it's somewhat difficult for me to
> decide how it would be better to split the information between these two
> pages and what should be the pages internal structure.
>
> I even thought about possibility of adding relatively comprehensive
> description of userfaultfd as man7/userfaultfd.7 and then keeping the pages
> in man2 relatively small, just with brief description of APIs and SEE ALSO
> pointing to man7.
>
> Any advise is highly appreciated.

I'm not averse to the notion of a userfaultfd.7 page, but it's a
little hard to advise because I'm not sure of the size and scope of
your planned changes.

In the meantime, I've merged the userfaultfd pages into master,
dropped the "draft" branch, and pushed the updates in master to Git.

Can you write your changes as a series of patches, and perhaps first
give a brief oultine of the proposed changes before getting too far
into the work? Then we could tweak the direction if needed.

Cheers,

Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
