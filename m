Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5656B0024
	for <linux-mm@kvack.org>; Sat, 14 May 2011 13:43:37 -0400 (EDT)
Date: Sat, 14 May 2011 19:43:33 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Message-ID: <20110514174333.GW6008@one.firstfloor.org>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com> <m2fwokj0oz.fsf@firstfloor.org> <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com> <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com> <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com> <20110514165346.GV6008@one.firstfloor.org> <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org

Copying back linux-mm.

> Recently, we added following patch.
> https://lkml.org/lkml/2011/4/26/129
> If it's a culprit, the patch should solve the problem.

It would be probably better to not do the allocations at all under 
memory pressure.  Even if the RA allocation doesn't go into reclaim
it may still "steal" allocations recently freed and needed by other
actors.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
