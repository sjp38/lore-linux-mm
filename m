Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 32BCE6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 13:31:30 -0400 (EDT)
Received: by igbue6 with SMTP id ue6so77520227igb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:31:30 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id 129si18695423ion.55.2015.03.18.10.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 10:31:29 -0700 (PDT)
Received: by igbue6 with SMTP id ue6so51118253igb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:31:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
References: <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
	<20150309191943.GF26657@destitution>
	<CA+55aFzFt-vX5Jerci0Ty4Uf7K4_nQ7wyCp8hhU_dB0X4cBpVQ@mail.gmail.com>
	<20150312131045.GE3406@suse.de>
	<CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
	<20150312184925.GH3406@suse.de>
	<20150317070655.GB10105@dastard>
	<CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
	<20150317205104.GA28621@dastard>
	<CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
	<20150317220840.GC28621@dastard>
	<CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
Date: Wed, 18 Mar 2015 10:31:28 -0700
Message-ID: <CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, Mar 18, 2015 at 9:08 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So why am I wrong? Why is testing for dirty not the same as testing
> for writable?
>
> I can see a few cases:
>
>  - your load has lots of writable (but not written-to) shared memory

Hmm. I tried to look at the xfsprog sources, and I don't see any
MAP_SHARED activity.  It looks like it's just using pread64/pwrite64,
and the only MAP_SHARED is for the xfsio mmap test thing, not for
xfsrepair.

So I don't see any shared mappings, but I don't know the code-base.

>  - something completely different that I am entirely missing

So I think there's something I'm missing. For non-shared mappings, I
still have the idea that pte_dirty should be the same as pte_write.
And yet, your testing of 3.19 shows that it's a big difference.
There's clearly something I'm completely missing.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
