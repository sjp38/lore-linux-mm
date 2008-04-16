Date: Wed, 16 Apr 2008 20:48:16 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][patch 2/5] mm: Node-setup agnostic free_bootmem()
Message-ID: <20080416184816.GA4400@elte.hu>
References: <20080416113629.947746497@skyscraper.fehenstaub.lan> <20080416113719.092060936@skyscraper.fehenstaub.lan> <86802c440804161054h6f0cfc3dmde49006afb7889b2@mail.gmail.com> <86802c440804161144id4f2a68i37513ac0428c693@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440804161144id4f2a68i37513ac0428c693@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>
List-ID: <linux-mm.kvack.org>

* Yinghai Lu <yhlu.kernel@gmail.com> wrote:

> >  Yes, it should work well with cross nodes case.
> >
> >  but please add boundary check on free_bootmem_node too.
> 
> also please note: it will have problem span nodes box.
> 
> for example: node 0: 0-2g, 4-6g, node1: 2-4g, 6-8g. and if ramdisk sit 
> creoss 2G boundary. you will only free the range before 2g.

yes. Such systems _will_ become more common - so the "this is rare" 
arguments are incorrect. bootmem has to be robust enough to deal with 
it.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
