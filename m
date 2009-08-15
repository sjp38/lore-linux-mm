Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2CC436B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 02:15:31 -0400 (EDT)
Date: Sat, 15 Aug 2009 13:32:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090815053208.GA11387@localhost>
References: <4A843565.3010104@redhat.com> <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com> <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost> <9EECC02A4CC333418C00A85D21E89326B6611AC5@azsmsx502.amr.corp.intel.com> <4A85E722.8030706@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A85E722.8030706@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 15, 2009 at 06:37:22AM +0800, Rik van Riel wrote:
> Dike, Jeffrey G wrote:
> > A side note - I've been doing some tracing and shrink_active_list
> > is called a humongous number of times (25000-ish during a ~90 kvm
> > run), with a net result of zero pages moved nearly all the time.

Your mean "no pages get deactivated at all in most invocations"?
This is possible in the steady (thrashing) state of a memory tight
system(the working set is bigger than memory size). 

> > Your test is rescuing essentially all candidate pages from the
> > inactive list.  Right now, I have the VM_EXEC || PageAnon version
> > of your test.
> 
> That is exactly why the the split LRU VM does an unconditional
> deactivation of active anon pages :)

In general it is :)  However in Jeff's small memory case, there
will be many refaults without the "PageAnon" protection. But the
patch does not imply that I'm happy with the "PageAnon" test ;)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
