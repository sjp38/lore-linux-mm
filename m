Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 476486B008A
	for <linux-mm@kvack.org>; Sun, 10 May 2009 06:06:30 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1194214yxh.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 03:06:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090510093541.GB7651@localhost>
References: <20090503031539.GC5702@localhost>
	 <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <1241946446.6317.42.camel@laptop> <20090510093541.GB7651@localhost>
Date: Sun, 10 May 2009 19:06:34 +0900
Message-ID: <2f11576a0905100306q3c087da8td834026a5161fe68@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> I don't think this is desirable, like Andrew already said, there's tons
>> of ways to defeat any of this and we've so far always priorized mappings
>> over !mappings. Limiting this to only PROT_EXEC mappings is already less
>> than it used to be.
>
> Yeah. One thing I realized in readahead is that *anything* can happen.
> When it comes to caching, app/user behaviors are *far more* unpredictable.
> We can make the heuristics as large as 1000LOC (and leave users and
> ourselves lost in the mist) or as simple as 100LOC (and make it happy
> to hacking or even abuse).

umm. I think it isn't good example.
Please see recent_scan/rotate stastics. it use only less 100LOC.

Plus, I don't think stastics is wrong.
if the page can claim "I'm high priority", it's risky. bad userland
program might exploit this rule.
but if the page claim "I think PROT_EXEC is important, maybe", it
isn't risky. if user-program want to exploit the rule, kernel ignore
the claim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
