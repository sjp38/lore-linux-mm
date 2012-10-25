Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0A2086B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:10:09 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1459170wgb.26
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:10:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351175972.12171.14.camel@twins>
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
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 Oct 2012 16:09:48 -0700
Message-ID: <CA+55aFzoxMYLXdBvdMYTy_LhrVuU233qh1eDyAda5otUTHojPA@mail.gmail.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 25, 2012 at 7:39 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> So I think the below should work, we hold the spinlock over both rb-tree
> modification as sp free, this makes mpol_shared_policy_lookup() which
> returns the policy with an incremented refcount work with just the
> spinlock.
>
> Comments?

Looks reasonable, if annoyingly complex for something that shouldn't
be important enough for this. Oh well.

However, please check me on this: the need for this is only for
linux-next right now, correct? All the current users in my tree are ok
with just the mutex, no?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
