Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 88D1D6B008C
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 02:12:20 -0500 (EST)
Message-ID: <4B0CD8D0.20600@cs.helsinki.fi>
Date: Wed, 25 Nov 2009 09:12:16 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: lockdep complaints in slab allocator
References: <1259086459.4531.1752.camel@laptop> <1259090615.17871.696.camel@calx> <1259095580.4531.1788.camel@laptop> <1259096004.17871.716.camel@calx> <1259096519.4531.1809.camel@laptop> <alpine.DEB.2.00.0911241302370.6593@chino.kir.corp.google.com> <1259097150.4531.1822.camel@laptop> <alpine.DEB.2.00.0911241313220.12339@chino.kir.corp.google.com> <1259098552.4531.1857.camel@laptop> <alpine.DEB.2.00.0911241336550.12339@chino.kir.corp.google.com> <20091124222351.GL6831@linux.vnet.ibm.com>
In-Reply-To: <20091124222351.GL6831@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Paul E. McKenney kirjoitti:
> As for me, as long as SLAB is in the kernel and is default for some
> of the machines I use for testing, I will continue reporting any bugs
> I find in it.  ;-)

Yes, thanks for doing that. As long as SLAB is in the tree, I'll do my 
best to get them fixed.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
