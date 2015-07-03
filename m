Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 41376280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 11:03:14 -0400 (EDT)
Received: by igblr2 with SMTP id lr2so78777456igb.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 08:03:14 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id lr8si5525070igb.57.2015.07.03.08.03.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 08:03:13 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so78454248iec.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 08:03:13 -0700 (PDT)
Message-ID: <5596A42F.60901@gmail.com>
Date: Fri, 03 Jul 2015 11:03:11 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com> <20150703144635.GE9456@thunk.org> <5596A20F.6010509@gmail.com> <20150703150117.GA3688@dhcp22.suse.cz>
In-Reply-To: <20150703150117.GA3688@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-03 11:01 AM, Michal Hocko wrote:
> On Fri 03-07-15 10:54:07, nick wrote:
> [...]
>> Did you even look at the other patches I send you. Here is a bug fix
>> for the gma500 driver code that someone else stated is right but I
>> don't have the hardware so it's difficult to test.
> 
> This is really annoying. Please stop it! Ted is not maintainer of the
> code you are trying to patch. There is absolutely no reason to try to
> persuate him or try to push it through him. Go and try to "sell" your
> patch to the maintainers of the said code.
> 
Michael,
The reason I am doing this is Ted is trying to find a bug that I fixed in order to prove
to Greg Kroah Hartman I have changed. Otherwise I would be pushing this through the
drm maintainer(s).
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
