Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0CD7D6B0055
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:26:40 -0400 (EDT)
Received: by fxm2 with SMTP id 2so216431fxm.38
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 07:26:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0906301014060.6124@gentwo.org>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
	 <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
	 <1246315553.21295.100.camel@calx>
	 <alpine.DEB.1.10.0906291910130.32637@gentwo.org>
	 <1246320394.21295.105.camel@calx>
	 <20090630060031.GL7070@linux.vnet.ibm.com>
	 <84144f020906292358j6517b599n471eed4e88781a78@mail.gmail.com>
	 <alpine.DEB.1.10.0906301014060.6124@gentwo.org>
Date: Tue, 30 Jun 2009 17:26:39 +0300
Message-ID: <84144f020906300726n4978d59ale5c8a3c076a1501a@mail.gmail.com>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem in
	sl[aou]b
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: paulmck@linux.vnet.ibm.com, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, 30 Jun 2009, Pekka Enberg wrote:
>> I don't even claim to understand all the RCU details here but I don't
>> see why we should care about _kmem_cache_destroy()_ performance at
>> this level. Christoph, hmmm?

On Tue, Jun 30, 2009 at 5:20 PM, Christoph
Lameter<cl@linux-foundation.org> wrote:
> Well it was surprising to me that kmem_cache_destroy() would perform rcu
> actions in the first place. RCU is usually handled externally and not
> within the slab allocator. The only reason that SLAB_DESTROY_BY_RCU exists
> is because the user cannot otherwise control the final release of memory
> to the page allocator.

Right. A quick grep for git logs reveals that it's been like that in
mm/slab.c at least since 2.6.12-rc2 so I think we should consider it
as part of the slab API and Paul's patch is an obvious bugfix to it.

                                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
