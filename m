Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 31C4F280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 11:01:23 -0400 (EDT)
Received: by wiar9 with SMTP id r9so133724223wia.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 08:01:22 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id iz2si36897742wic.101.2015.07.03.08.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 08:01:21 -0700 (PDT)
Received: by wgck11 with SMTP id k11so90674745wgc.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 08:01:20 -0700 (PDT)
Date: Fri, 3 Jul 2015 17:01:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
Message-ID: <20150703150117.GA3688@dhcp22.suse.cz>
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com>
 <20150702072621.GB12547@dhcp22.suse.cz>
 <20150702160341.GC9456@thunk.org>
 <55956204.2060006@gmail.com>
 <20150703144635.GE9456@thunk.org>
 <5596A20F.6010509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5596A20F.6010509@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 03-07-15 10:54:07, nick wrote:
[...]
> Did you even look at the other patches I send you. Here is a bug fix
> for the gma500 driver code that someone else stated is right but I
> don't have the hardware so it's difficult to test.

This is really annoying. Please stop it! Ted is not maintainer of the
code you are trying to patch. There is absolutely no reason to try to
persuate him or try to push it through him. Go and try to "sell" your
patch to the maintainers of the said code.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
