Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7526B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 19:07:56 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j15so373575017ioj.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 16:07:56 -0800 (PST)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id x63si486958itg.104.2017.01.05.16.07.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 16:07:55 -0800 (PST)
Received: by mail-it0-x241.google.com with SMTP id b123so567437itb.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 16:07:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105160202.baa14f400bfd906466a915db@linux-foundation.org>
References: <20170104023620.13451.80691.stgit@localhost.localdomain> <20170105160202.baa14f400bfd906466a915db@linux-foundation.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 5 Jan 2017 16:07:54 -0800
Message-ID: <CAKgT0UddTYqrje-FSJAcicsDC4oAjgOaPmADk=g+W272+MUeow@mail.gmail.com>
Subject: Re: [next PATCH v4 0/3] Page fragment updates
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jan 5, 2017 at 4:02 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 03 Jan 2017 18:38:48 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> This patch series takes care of a few cleanups for the page fragments API.
>>
>> First we do some renames so that things are much more consistent.  First we
>> move the page_frag_ portion of the name to the front of the functions
>> names.  Secondly we split out the cache specific functions from the other
>> page fragment functions by adding the word "cache" to the name.
>>
>> Finally I added a bit of documentation that will hopefully help to explain
>> some of this.  I plan to revisit this later as we get things more ironed
>> out in the near future with the changes planned for the DMA setup to
>> support eXpress Data Path.
>>
>> ---
>>
>> v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages
>> v3: Updated first rename patch so that it is just a rename and doesn't impact
>>     the actual functionality to avoid performance regression.
>> v4: Fix mangling that occured due to a bad merge fix when patches 1 and 2
>>     were swapped and then swapped back.
>>
>> I'm submitting this to Intel Wired Lan and Jeff Kirsher's "next-queue" for
>> acceptance as I have a series of other patches for igb that are blocked by
>> by these patches since I had to rename the functionality fo draining extra
>> references.
>>
>> This series was going to be accepted for mmotm back when it was v1, however
>> since then I found a few minor issues that needed to be fixed.
>>
>> I am hoping to get an Acked-by from Andrew Morton for these patches and
>> then have them submitted to David Miller as he has said he will accept them
>> if I get the Acked-by.  In the meantime if these can be applied to
>> next-queue while waiting on that Acked-by then I can submit the other
>> patches for igb and ixgbe for testing.
>
> The patches look fine.  How about I just scoot them straight into
> mainline next week?  I do that occasionally, just to simplify ongoing
> development and these patches are safe enough.

That should work for me.

Thanks.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
