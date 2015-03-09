Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id B2BF86B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 12:52:19 -0400 (EDT)
Received: by igbhn18 with SMTP id hn18so22681855igb.2
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 09:52:19 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id dy6si13412852icb.37.2015.03.09.09.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 09:52:19 -0700 (PDT)
Received: by iecrd18 with SMTP id rd18so14150700iec.12
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 09:52:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150309112936.GD26657@destitution>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-5-git-send-email-mgorman@suse.de>
	<20150307163657.GA9702@gmail.com>
	<CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
	<20150308100223.GC15487@gmail.com>
	<CA+55aFyQyZXu2fi7X9bWdSX0utk8=sccfBwFaSoToROXoE_PLA@mail.gmail.com>
	<20150309112936.GD26657@destitution>
Date: Mon, 9 Mar 2015 09:52:18 -0700
Message-ID: <CA+55aFywW5JLq=BU_qb2OG5+pJ-b1v9tiS5Ygi-vtEKbEZ_T5Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Mon, Mar 9, 2015 at 4:29 AM, Dave Chinner <david@fromorbit.com> wrote:
>
>> Also, is there some sane way for me to actually see this behavior on a
>> regular machine with just a single socket? Dave is apparently running
>> in some fake-numa setup, I'm wondering if this is easy enough to
>> reproduce that I could see it myself.
>
> Should be - I don't actually use 500TB of storage to generate this -
> 50GB on an SSD is all you need from the storage side. I just use a
> sparse backing file to make it look like a 500TB device. :P

What's your virtual environment setup? Kernel config, and
virtualization environment to actually get that odd fake NUMA thing
happening?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
