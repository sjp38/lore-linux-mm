Received: by rv-out-0506.google.com with SMTP id g37so188987rvb.26
        for <linux-mm@kvack.org>; Thu, 17 Apr 2008 22:06:22 -0700 (PDT)
Message-ID: <86802c440804172206k7533e7d1kf1f355f6a97a4412@mail.gmail.com>
Date: Thu, 17 Apr 2008 22:06:22 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC][patch 2/5] mm: Node-setup agnostic free_bootmem()
In-Reply-To: <877iexfw2h.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080416113629.947746497@skyscraper.fehenstaub.lan>
	 <20080416113719.092060936@skyscraper.fehenstaub.lan>
	 <86802c440804161054h6f0cfc3dmde49006afb7889b2@mail.gmail.com>
	 <86802c440804161144id4f2a68i37513ac0428c693@mail.gmail.com>
	 <20080416184816.GA4400@elte.hu> <877iexfw2h.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Ingo Molnar <mingo@elte.hu>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 16, 2008 at 12:17 PM, Johannes Weiner <hannes@saeurebad.de> wrote:
> Hi,
>
>
>
>  Ingo Molnar <mingo@elte.hu> writes:
>
>  > * Yinghai Lu <yhlu.kernel@gmail.com> wrote:
>  >
>  >> >  Yes, it should work well with cross nodes case.
>  >> >
>  >> >  but please add boundary check on free_bootmem_node too.
>  >>
>  >> also please note: it will have problem span nodes box.
>  >>
>  >> for example: node 0: 0-2g, 4-6g, node1: 2-4g, 6-8g. and if ramdisk sit
>  >> creoss 2G boundary. you will only free the range before 2g.
>  >
>  > yes. Such systems _will_ become more common - so the "this is rare"
>  > arguments are incorrect. bootmem has to be robust enough to deal with
>  > it.
>
>  Ingo, I never doubted any of this, I was just asking more than once if
>  and when this might happen.  And I don't want the allocator become
>  fragile, just not completely ignorant about bogus input.
>
>  But the situation is still not clear for me.  Ingo, how are these
>  node spanning pfn ranges represented in the kernel?  How many node
>  descriptors will you have in the case Yinghai described and how will
>  they look like?

according to patch from Suresh in x86.git, one node still only have one bdata.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
