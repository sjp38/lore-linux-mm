Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 36146900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 20:42:26 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1424159vxg.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 17:42:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E028215.90107@redhat.com>
References: <201106212055.25400.nai.xia@gmail.com>
	<201106212132.39311.nai.xia@gmail.com>
	<4E01C752.10405@redhat.com>
	<4E01CC77.10607@ravellosystems.com>
	<4E01CDAD.3070202@redhat.com>
	<4E01CFD2.6000404@ravellosystems.com>
	<4E020CBC.7070604@redhat.com>
	<20110622165529.GY20843@redhat.com>
	<BANLkTinRYr9Vg==C-qyCaRmO7C_aQqBPzw@mail.gmail.com>
	<4E028215.90107@redhat.com>
Date: Thu, 23 Jun 2011 08:42:24 +0800
Message-ID: <BANLkTi=oNXAmYaC44EYnNRU2_4KFoJjubw@mail.gmail.com>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On Thu, Jun 23, 2011 at 8:00 AM, Rik van Riel <riel@redhat.com> wrote:
> On 06/22/2011 07:37 PM, Nai Xia wrote:
>
>> On 2MB pages, I'd like to remind you and Rik that ksmd currently splits
>> huge pages before their sub pages gets really merged to stable tree.
>
> Your proposal appears to add a condition that causes ksmd to skip
> doing that, which can cause the system to start using swap instead
> of sharing memory.

Hmm, yes, no swapping. So we should make the checksum default
for huge pages, right?

>
>> So when there are many 2MB pages each having a 4kB subpage
>> changed for all time, this is already a concern for ksmd to judge
>> if it's worthwhile to split 2MB page and get its sub-pages merged.
>> I think the policy for ksmd in a system should be "If you cannot do sth
>> good,
>> at least do nothing evil". So I really don't think we can satisfy _all_
>> people.
>> Get a general method and give users one or two knobs to tune it when the=
y
>> are the corner cases. How do =A0you think of my proposal ?
>
> I think your proposal makes sense for 4kB pages, but the ksmd
> policy for 2MB pages probably needs to be much more aggressive.

I now agree with you on the whole point. Let's fall back to checksum
Thanks for make my mind clear! :)

And shall we provide a interface to users if he _really_ what to judge the =
dirty
bit from the pmd level? I think we should agree to one point before I
misunderstand
you and spam you with my next submission :P


And thanks for your time viewing!

-Nai


>
> --
> All rights reversed
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
