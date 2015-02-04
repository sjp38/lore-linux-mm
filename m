Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3B7900024
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 18:14:43 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id s11so3976369qcv.5
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 15:14:43 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com. [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id q67si3865677qgd.39.2015.02.04.15.14.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Feb 2015 15:14:42 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id v8so3520941qal.7
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 15:14:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54930835.8020009@codeaurora.org>
References: <1418854236-25140-1-git-send-email-gregory.0xf0@gmail.com> <54930835.8020009@codeaurora.org>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Wed, 4 Feb 2015 15:14:11 -0800
Message-ID: <CADtm3G4c8GH5v3p8Qhf02jPcdRPVu+4MmjfD-2S8ZpoK0-b0Ew@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: cma: add functions for getting allocation info
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, open list <linux-kernel@vger.kernel.org>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>

On Thu, Dec 18, 2014 at 9:00 AM, Laura Abbott <lauraa@codeaurora.org> wrote=
:
> On 12/17/2014 2:10 PM, Gregory Fong wrote:
>>
>> These functions allow for retrieval of information on what is allocated =
from
>> within a given CMA region.  It can be useful to know the number of disti=
nct
>> contiguous allocations and where in the region those allocations are
>> located.
>>
>> Based on an initial version by Marc Carino <marc.ceeeee@gmail.com> in a =
driver
>> that used the CMA bitmap directly; this instead moves the logic into the=
 core
>> CMA API.
>>
>> Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
>> ---
>> This has been really useful for us to determine allocation information f=
or a
>> CMA region.  We have had a separate driver that might not be appropriate=
 for
>> upstream, but allowed using a user program to run CMA unit tests to veri=
fy that
>> allocations end up where they we would expect.  This addition would allo=
w for
>> that without needing to expose the CMA bitmap.  Wanted to put this out t=
here to
>> see if anyone else would be interested, comments and suggestions welcome=
.
>>
>
> Information is definitely useful but I'm not sure how it's intended to
> be used. Do you have a sample usage of these APIs? Another option might
> be to just add regular debugfs support for each of the regions instead
> of just calling out to a separate driver.

Sorry for the late reply, got way behind on emails.

Some background is probably good to start here: we use CMA to provide
very large (hundreds of MiB) contiguous regions for an out-of-kernel
allocator to divvy up according to varying platform requirements.
It's an unusual configuration but one that we're stuck with for now.

After having some time to think about this more and taking into
consideration yours and Micha=C5=82's reply, this definitely does not seem
like the proper approach.  Something better would probably be like
what Stefan is working on[1], so I'll wait to see his v2 that uses
debugfs instead.

[1] https://lkml.org/lkml/2014/12/26/95

Thanks,
Gregory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
