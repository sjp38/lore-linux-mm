Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEDC6B0005
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 22:00:34 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id ig19so9685667igb.1
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 19:00:34 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id u23si3293406ioi.14.2016.03.06.19.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Mar 2016 19:00:33 -0800 (PST)
Message-ID: <1457319627.19197.1.camel@ellerman.id.au>
Subject: Re: Problems with swapping in v4.5-rc on POWER
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 07 Mar 2016 14:00:27 +1100
In-Reply-To: <alpine.LSU.2.11.1603040948250.5477@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
	 <877fhttmr1.fsf@linux.vnet.ibm.com>
	 <alpine.LSU.2.11.1602242136270.6876@eggly.anvils>
	 <alpine.LSU.2.11.1602251322130.8063@eggly.anvils>
	 <alpine.LSU.2.11.1602260157430.10399@eggly.anvils>
	 <alpine.LSU.2.11.1603021226300.31251@eggly.anvils>
	 <1456984266.28236.1.camel@ellerman.id.au>
	 <alpine.LSU.2.11.1603040948250.5477@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Fri, 2016-03-04 at 09:58 -0800, Hugh Dickins wrote:
> 
> The alternative bisection was as unsatisfactory as the first:
> again it fingered an irrelevant merge (rather than any commit
> pulled in by that merge) as the bad commit.
> 
> It seems this issue is too intermittent for bisection to be useful,
> on my load anyway.

Darn. Thanks for trying.

> The best I can do now is try v4.4 for a couple of days, to verify that
> still comes out good (rather than the machine going bad coincident with
> v4.5-rc), then try v4.5-rc7 to verify that that still comes out bad.

Thanks, that would still be helpful.

> I'll report back on those; but beyond that, I'll have to leave it to you.

I haven't had any luck here :/

Can you give us a more verbose description of your test setup?

 - G5, which exact model?
 - 4k pages, no THP.
 - how much ram & swap?
 - building linus' tree, make -j ?
 - source and output on tmpfs? (how big?)
 - what device is the swap device? (you said SSD I think?)
 - anything else I've forgotten?

Oh and can you send us your bisect logs, we can at least trust the bad results
I think.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
