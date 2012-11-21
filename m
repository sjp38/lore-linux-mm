Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EE3B86B007D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:00:22 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so5804952iaj.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 17:00:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+1xoqcbPGpFvhJG3OMDYBPMD0+1umJv1wyE-b+KHtKi_s4unQ@mail.gmail.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
 <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com>
 <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>
 <CA+1xoqd6MEFP-eWdnWOrcz2EmE6tpd7UhgJyS8HjQ8qrGaMMMw@mail.gmail.com>
 <alpine.DEB.2.00.1210241659260.22819@chino.kir.corp.google.com>
 <1351167554.23337.14.camel@twins> <1351175972.12171.14.camel@twins>
 <CA+55aFzoxMYLXdBvdMYTy_LhrVuU233qh1eDyAda5otUTHojPA@mail.gmail.com>
 <1351241323.12171.43.camel@twins> <CA+1xoqcbPGpFvhJG3OMDYBPMD0+1umJv1wyE-b+KHtKi_s4unQ@mail.gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Tue, 20 Nov 2012 19:59:57 -0500
Message-ID: <CA+1xoqevFYQqBOKWZAL5ye6Mef+ZJkTra7UzOTkGmeCJmm-LPA@mail.gmail.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Ping? Can someone take it before it's lost?

On Wed, Oct 31, 2012 at 2:29 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> On Fri, Oct 26, 2012 at 4:48 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> On Thu, 2012-10-25 at 16:09 -0700, Linus Torvalds wrote:
>>> On Thu, Oct 25, 2012 at 7:39 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>> >
>>> > So I think the below should work, we hold the spinlock over both rb-tree
>>> > modification as sp free, this makes mpol_shared_policy_lookup() which
>>> > returns the policy with an incremented refcount work with just the
>>> > spinlock.
>>> >
>>> > Comments?
>>>
>>> Looks reasonable, if annoyingly complex for something that shouldn't
>>> be important enough for this. Oh well.
>>
>> I agree with that.. Its just that when doing numa placement one needs to
>> respect the pre-existing placement constraints. I've not seen a way
>> around this.
>>
>>> However, please check me on this: the need for this is only for
>>> linux-next right now, correct? All the current users in my tree are ok
>>> with just the mutex, no?
>>
>> Yes, the need comes from the numa stuff and I'll stick this patch in
>> there.
>>
>> I completely missed Mel's patch turning it into a mutex, but I guess
>> that's what -next is for :-).
>
> So I've been fuzzing with it for the past couple of days and it's been
> looking fine with it. Can someone grab it into his tree please?
>
>
> Thanks,
> Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
