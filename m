Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id B881C6B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 16:58:07 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so727954eek.29
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:58:07 -0700 (PDT)
Received: from radon.swed.at (b.ns.miles-group.at. [95.130.255.144])
        by mx.google.com with ESMTPS id l44si309980eem.313.2014.05.04.13.58.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 13:58:05 -0700 (PDT)
Message-ID: <5366A9D9.8000100@nod.at>
Date: Sun, 04 May 2014 22:58:01 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [3.15rc1] BUG at mm/filemap.c:202!
References: <20140415190936.GA24654@redhat.com> <alpine.LSU.2.11.1404161239320.6778@eggly.anvils> <CAFLxGvxZxWf6nzJ5cXM--b02axz9u8UL_MTUyo3WgLPvbpCFAg@mail.gmail.com> <CAFLxGvxPV9+BgP=CVEp4kLbedOYBEui9uYddNTDix=ENrrusoQ@mail.gmail.com> <alpine.LSU.2.11.1405041311130.3230@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405041311130.3230@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Am 04.05.2014 22:37, schrieb Hugh Dickins:
> On Sat, 3 May 2014, Richard Weinberger wrote:
>> On Thu, May 1, 2014 at 6:20 PM, Richard Weinberger
>> <richard.weinberger@gmail.com> wrote:
>>> On Wed, Apr 16, 2014 at 10:40 PM, Hugh Dickins <hughd@google.com> wrote:
>>>>
>>>> Help!
>>>
>>> Using a trinity as of today I'm able to trigger this bug on UML within seconds.
>>> If you want me to test patch, I can help.
>>>
>>> I'm also observing one strange fact, I can trigger this on any kernel version.
>>> So far I've managed UML to crash on 3.0 to 3.15-rc...
>>
>> After digging deeper into UML's mmu and tlb code I've found issues and
>> fixed them.
>>
>> But I'm still facing this issue. Although triggering the BUG_ON() is
>> not so easy as before
>> I can trigger "BUG: Bad rss-counter ..." very easily.
>> Now the interesting fact, with my UML mmu and flb fixes applied it
>> happens only on kernels >= 3.14.
>> If it helps I can try to bisect it.
> 
> Thanks a lot for trying, but from other mail it looks like your
> bisection got blown off course ;(

Yeah, looks like the issue I'm facing on UML is a completely different
story. Although the symptoms are identical. :-(

> I expect for the moment you'll want to concentrate on getting UML's
> TLB flushing back on track with 3.15-rc.

This is what I'm currently doing. But it might take some time
as I'm a mm novice.

> Once you have that sorted out, I wouldn't be surprised if the same
> changes turn out to fix your "Bad rss-counter"s on 3.14 also.
> 
> If not, and if you do still have time to bisect back between 3.13 and
> 3.14 to find where things went wrong, it will be a bit tedious in that
> you would probably have to apply
> 
> 887843961c4b "mm: fix bad rss-counter if remap_file_pages raced migration"
> 7e09e738afd2 "mm: fix swapops.h:131 bug if remap_file_pages raced migration"
> 
> at each stage, to avoid those now-known bugs which trinity became rather
> good at triggering.  Perhaps other fixes needed, those the two I remember.
> 
> Please don't worry if you don't have time for this, that's understandable.
> 
> Or is UML so contrary that one of those commits actually brings on the
> problem for you?

Hehe, no. I gave it a quick try, both 887843961c4b and 7e09e738afd2
seem to be unrelated to the issues I see.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
