Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14ABC6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 20:17:29 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id x1so26214660pav.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 17:17:29 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id w1si54172114pfj.95.2016.06.01.17.17.28
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 17:17:28 -0700 (PDT)
Subject: Re: [PATCH 5/8] x86, pkeys: allocation/free syscalls
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152822.FE8D405E@viggo.jf.intel.com>
 <20160601123705.72a606e7@lwn.net> <574F386A.8070106@sr71.net>
 <CAKgNAkiyD_2tAxrBxirxViViMUsfLRRqQp5HowM58dG21LAa7Q@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <574F7B16.4080906@sr71.net>
Date: Wed, 1 Jun 2016 17:17:26 -0700
MIME-Version: 1.0
In-Reply-To: <CAKgNAkiyD_2tAxrBxirxViViMUsfLRRqQp5HowM58dG21LAa7Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Jonathan Corbet <corbet@lwn.net>, lkml <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 06/01/2016 05:11 PM, Michael Kerrisk (man-pages) wrote:
>>> >>
>>> >> If I read this right, it doesn't actually remove any pkey restrictions
>>> >> that may have been applied while the key was allocated.  So there could be
>>> >> pages with that key assigned that might do surprising things if the key is
>>> >> reallocated for another use later, right?  Is that how the API is intended
>>> >> to work?
>> >
>> > Yeah, that's how it works.
>> >
>> > It's not ideal.  It would be _best_ if we during mm_pkey_free(), we
>> > ensured that no VMAs under that mm have that vma_pkey() set.  But, that
>> > search would be potentially expensive (a walk over all VMAs), or would
>> > force us to keep a data structure with a count of all the VMAs with a
>> > given key.
>> >
>> > I should probably discuss this behavior in the manpages and address it
> s/probably//
> 
> And, did I miss it. Was there an updated man-pages patch in the latest
> series? I did not notice it.

There have been to changes to the patches that warranted updating the
manpages until now.  I'll send the update immediately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
