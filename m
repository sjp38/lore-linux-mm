Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 1800B6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:45:12 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:45:01 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
Message-ID: <20121017194501.GA24400@redhat.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com>
 <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
 <20121017181413.GA16805@redhat.com>
 <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com>
 <20121017193229.GC16805@redhat.com>
 <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 17, 2012 at 12:38:55PM -0700, David Rientjes wrote:

 > >  > Sounds good.  Is it possible to verify that policy_cache isn't getting 
 > >  > larger than normal in /proc/slabinfo, i.e. when all processes with a 
 > >  > task mempolicy or shared vma policy have exited, are there still a 
 > >  > significant number of active objects?
 > > 
 > > Killing the fuzzer caused it to drop dramatically.
 > > 
 > Excellent, thanks.  This shows that the refcounting is working properly 
 > and we're not leaking any references as a result of this change causing 
 > the mempolicies to never be freed.  ("numa_policy" turns out to be 
 > policy_cache in the code, so thanks for checking both of them.)
 > 
 > Could I add your tested-by?

Sure. Here's a fresh one I just baked.

Tested-by: Dave Jones <davej@redhat.com>

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
