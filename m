Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id A60EB6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 18:11:08 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t67so62173199ywg.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 15:11:08 -0700 (PDT)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id k41si308392qta.5.2016.09.14.15.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 15:11:07 -0700 (PDT)
From: "Raslan, KarimAllah" <karahmed@amazon.de>
Subject: Re: [PATCH] sparse: Track the boundaries of memory sections for
 accurate checks
Date: Wed, 14 Sep 2016 22:11:00 +0000
Message-ID: <7D63A80D-53B7-460A-A74D-0005B7D499D6@amazon.de>
References: <1466244679-23824-1-git-send-email-karahmed@amazon.de>
 <20160620082339.GC4340@dhcp22.suse.cz>
 <8B91B5C5-4506-40CB-B7F0-0990A37F95AA@amazon.de>
 <CAPcyv4gQZ-=6SdsGc-YafcAUz0WWxtGuh56CPan1xqSkWbd9=A@mail.gmail.com>
In-Reply-To: <CAPcyv4gQZ-=6SdsGc-YafcAUz0WWxtGuh56CPan1xqSkWbd9=A@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <93E79DEE98FC1B47AC7071613EE0BE6A@ant.amazon.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>, "Liguori, Anthony" <aliguori@amazon.com>, "Schoenherr, Jan
 H." <jschoenh@amazon.de>


Ahmed, Karim Allah
karahmed@amazon.de



> On Sep 15, 2016, at 12:05 AM, Dan Williams <dan.j.williams@intel.com> wro=
te:
> =

> On Wed, Sep 14, 2016 at 2:40 PM, Raslan, KarimAllah <karahmed@amazon.de> =
wrote:
>> =

>> =

>> On 6/20/16, 10:23 AM, "Michal Hocko" <mhocko@kernel.org> wrote:
>> =

>>    On Sat 18-06-16 12:11:19, KarimAllah Ahmed wrote:
>>> When sparse memory model is used an array of memory sections is created=
 to
>>> track each block of contiguous physical pages. Each element of this arr=
ay
>>> contains PAGES_PER_SECTION pages. During the creation of this array the=
 actual
>>> boundaries of the memory block is lost, so the whole block is either co=
nsidered
>>> as present or not.
>>> =

>>> pfn_valid() in the sparse memory configuration checks which memory sect=
ions the
>>> pfn belongs to then checks whether it's present or not. This yields sub=
-optimal
>>> results when the available memory doesn't cover the whole memory sectio=
n,
>>> because pfn_valid will return 'true' even for the unavailable pfns at t=
he
>>> boundaries of the memory section.
>> =

>>    Please be more verbose of _why_ the patch is needed. Why those
>>    "sub-optimal results" matter?
>> =

>> Does this make sense to you ?
> =

> [ channeling my inner akpm ]
> =

> What's the user visible effect of this change?  What code is getting
> tripped up by pfn_valid() being imprecise, and why is changing
> pfn_valid() the preferred fix?

I did expand the commit message in v2 of this patch to answer these questio=
ns:

https://patchwork.kernel.org/patch/9190737/

Amazon Development Center Germany GmbH
Berlin - Dresden - Aachen
main office: Krausenstr. 38, 10117 Berlin
Geschaeftsfuehrer: Dr. Ralf Herbrich, Christian Schlaeger
Ust-ID: DE289237879
Eingetragen am Amtsgericht Charlottenburg HRB 149173 B

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
