Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 133EE6B003D
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 13:57:55 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so10252150wes.33
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 10:57:55 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id fx6si28888981wjb.172.2014.07.01.10.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 10:57:55 -0700 (PDT)
Date: Tue, 1 Jul 2014 19:57:54 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] hwpoison: Fix race with changing page during offlining
Message-ID: <20140701175753.GL5714@two.firstfloor.org>
References: <1403806972-14267-1-git-send-email-andi@firstfloor.org>
 <20140626195036.GA5311@nhori.redhat.com>
 <20140626125657.f1830a0b399cbe5a97071206@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140626125657.f1830a0b399cbe5a97071206@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, dave.hansen@linux.intel.com, Chen Yucong <slaoub@gmail.com>

> Andi, can you please check that and test?  If the patch is good I'll
> bump it into 3.16 with an enhanced changelog..

I think the original problem was a race, so it is not easy to reproduce.
I ran this patch in a loop over night with some stress plus 
the mcelog test suite running in a loop. I cannot guarantee it hit it,
but it should have given it a good beating.

The kernel survived with no messages, although the mcelog test suite
got killed at some point because it couldn't fork anymore. Probably
some unrelated problem.

So the patch is ok for me for .16.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
