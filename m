Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 433EE6B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 16:01:51 -0400 (EDT)
Received: by igui7 with SMTP id i7so19307923igu.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 13:01:51 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id r2si4550884ioe.21.2015.08.14.13.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Aug 2015 13:01:50 -0700 (PDT)
Received: by igui7 with SMTP id i7so19307739igu.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 13:01:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-2-git-send-email-ddstreet@ieee.org> <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
 <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com> <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 14 Aug 2015 16:01:10 -0400
Message-ID: <CALZtONAJUSDLfSdEzGx-AuKP9EHKw+ChLO+ZVnJ-NjoFe8zzYA@mail.gmail.com>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

>>On Wed, Aug 5, 2015 at 6:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>>> On Wed, 5 Aug 2015 18:00:26 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>>>
>>>> >
>>>> > If there's some reason why this can't happen, can we please have a code
>>>> > comment which reveals that reason?
>>>>
>>>> zpool_create_pool() should work if this returns true, unless as you
>>>> say the module is rmmod'ed *and* removed from the system - since
>>>> zpool_create_pool() will call request_module() just as this function
>>>> does.  I can add a comment explaining that.
>>>
>>> I like comments ;)
>>>
>>> Seth, I'm planning on sitting on these patches until you've had a
>>> chance to review them.
>>>
>>>
>> Thanks Andrew.  I'm reviewing now.  Patch 2/3 is pretty huge.  I've got
>> the gist of the changes now.  I'm also building and testing for myself
>> as this creates a lot more surface area for issues, alternating between
>> compressors and allocating new compression transforms on the fly.
>>
>> I'm kinda with Sergey on this in that it adds yet another complexity to
>> an already complex feature.  This adds more locking, more RCU, more
>> refcounting.  It's becoming harder to review, test, and verify.
>>
>> I should have results tomorrow.
>
>So I gave it a test run turning all the knobs (compressor, enabled,
>max_pool_percent, and zpool) like a crazy person and it was stable,
>and all the adjustments had the expected result.
>
>Dan, you might follow up with an update to Documentation/vm/zswap.txt
>noting that these parameters are runtime adjustable now.
>
>The growing complexity is a concern, but it is nice to have the
>flexibility.  Thanks for the good work!
>
>To patchset:
>
>Acked-by: Seth Jennings <sjennings@variantweb.net>
>

Hi Seth!

FYI, for whatever reason I'm still not directly getting your emails :(
 I use gmail, if that helps...I don't know if there's a problem on
your end or mine...at least this time I knew to check the list archive
;-)

Thanks for reviewing!  I'll send a patch to update zswap.txt also.

Andrew, would you prefer an additional patch to update zswap.txt, or
should I roll up that patch and the other few correction patches and
resend this patch set?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
