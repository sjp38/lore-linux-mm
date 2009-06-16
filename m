Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 157F66B0082
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 17:05:01 -0400 (EDT)
Message-ID: <4A380767.6080304@zytor.com>
Date: Tue, 16 Jun 2009 13:58:15 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <Pine.LNX.4.64.0906151341160.25162@sister.anvils> <20090615140019.4e405d37@lxorguk.ukuu.org.uk> <20090615132934.GE31969@one.firstfloor.org> <20090616194430.GA9545@sgi.com> <4A380086.7020904@zytor.com> <20090616205449.GA4858@sgi.com>
In-Reply-To: <20090616205449.GA4858@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russ Anderson <rja@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Russ Anderson wrote:
>>
>> However, the more fundamental thing is that it is always trivial to
>> promote an error to a higher severity; the opposite is not true.  As
>> such, it becomes an administrator-set policy, which is what it needs to be.
> 
> Good point.  On ia64 the recovery code is implemented as a kernel
> loadable module.  Installing the module turns on the feature.
> 
> That is handy for customer demos.  Install the module, inject a
> memory error, have an application read the bad data and get killed.
> Repeat a few times.  Then uninstall the module, inject a
> memory error, have an application read the bad data and watch
> the system panic.
> 
> Then it is the customer's choice to have it on or off.
> 

There are a number of ways to set escalation policy.  Modules isn't
necessarily the best, but it doesn't really matter what the exact
mechanism is.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
