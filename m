Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED8D900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 20:00:31 -0400 (EDT)
Message-ID: <4E028215.90107@redhat.com>
Date: Wed, 22 Jun 2011 20:00:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com>	<201106212132.39311.nai.xia@gmail.com>	<4E01C752.10405@redhat.com>	<4E01CC77.10607@ravellosystems.com>	<4E01CDAD.3070202@redhat.com>	<4E01CFD2.6000404@ravellosystems.com>	<4E020CBC.7070604@redhat.com>	<20110622165529.GY20843@redhat.com> <BANLkTinRYr9Vg==C-qyCaRmO7C_aQqBPzw@mail.gmail.com>
In-Reply-To: <BANLkTinRYr9Vg==C-qyCaRmO7C_aQqBPzw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/22/2011 07:37 PM, Nai Xia wrote:

> On 2MB pages, I'd like to remind you and Rik that ksmd currently splits
> huge pages before their sub pages gets really merged to stable tree.

Your proposal appears to add a condition that causes ksmd to skip
doing that, which can cause the system to start using swap instead
of sharing memory.

> So when there are many 2MB pages each having a 4kB subpage
> changed for all time, this is already a concern for ksmd to judge
> if it's worthwhile to split 2MB page and get its sub-pages merged.
> I think the policy for ksmd in a system should be "If you cannot do sth good,
> at least do nothing evil". So I really don't think we can satisfy _all_ people.
> Get a general method and give users one or two knobs to tune it when they
> are the corner cases. How do  you think of my proposal ?

I think your proposal makes sense for 4kB pages, but the ksmd
policy for 2MB pages probably needs to be much more aggressive.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
