Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 826066B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:27:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so8649273pbb.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:27:37 -0700 (PDT)
Date: Wed, 17 Oct 2012 14:27:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <CAHGf_=ojnEA6FG2eE_P6oAO-WtybAbTF8xNUMWb4geF4PXQbhA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210171426170.20712@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <507E4531.1070700@jp.fujitsu.com> <CAHGf_=rCbH7=6FX+PhhPUbixw-0TstdpTNzMEmXgQALbNAkGRg@mail.gmail.com> <alpine.DEB.2.00.1210171246290.28214@chino.kir.corp.google.com>
 <CAHGf_=ojnEA6FG2eE_P6oAO-WtybAbTF8xNUMWb4geF4PXQbhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Oct 2012, KOSAKI Motohiro wrote:

> > Um, this was just changed to a mutex last week in commit b22d127a39dd
> > ("mempolicy: fix a race in shared_policy_replace()") so that sp_alloc()
> > can be done with GFP_KERNEL, so I didn't consider reverting that behavior.
> > Are you nacking that patch, which you acked, now?
> 
> Yes, sadly. /proc usage is a corner case issue. It's not worth to
> strike main path.

It also simplifies the fastpath since we can now unconditionally drop the 
reference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
