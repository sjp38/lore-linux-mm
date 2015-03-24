Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 573246B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 16:23:31 -0400 (EDT)
Received: by igcau2 with SMTP id au2so82999574igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 13:23:31 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id ga12si9670465igd.34.2015.03.24.13.23.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 13:23:30 -0700 (PDT)
Received: by igcau2 with SMTP id au2so82999425igc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 13:23:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150324153306.GG4701@suse.de>
References: <1427113443-20973-1-git-send-email-mgorman@suse.de>
	<20150324115141.GS28621@dastard>
	<20150324153306.GG4701@suse.de>
Date: Tue, 24 Mar 2015 13:23:30 -0700
Message-ID: <CA+55aFzPCbfMKPEpxntCvEK_SqjbBTppyZMW7W2C+ppnA4W4fw@mail.gmail.com>
Subject: Re: [PATCH 0/3] Reduce system overhead of automatic NUMA balancing
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Mar 24, 2015 at 8:33 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Mar 24, 2015 at 10:51:41PM +1100, Dave Chinner wrote:
>>
>> So it looks like the patch set fixes the remaining regression and in
>> 2 of the four cases actually improves performance....
>
> \o/

W00t.

> Linus, these three patches plus the small fixlet for pmd_mkyoung (to match
> pte_mkyoung) is already in Andrew's tree. I'm expecting it'll arrive to
> you before 4.0 assuming nothing else goes pear shaped.

Yup. Thanks Mel,

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
