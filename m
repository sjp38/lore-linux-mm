Date: Wed, 8 Sep 2004 21:50:08 +0200
From: Diego Calleja <diegocg@teleline.es>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-Id: <20040908215008.10a56e2b.diegocg@teleline.es>
In-Reply-To: <Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com>
References: <5860000.1094664673@flay>
	<Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: mbligh@aracnet.com, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

El Wed, 08 Sep 2004 14:04:31 -0400 (EDT) Rik van Riel <riel@redhat.com> escribio:

> On Wed, 8 Sep 2004, Martin J. Bligh wrote:
> 
> > For HPC, maybe. For a fileserver, it might be far too little. That's the
> > trouble ... it's all dependant on the workload. Personally, I'd prefer
> > to get rid of manual tweakables (which are a pain in the ass in the field
> > anyway), and try to have the kernel react to what the customer is doing.
> 
> Agreed.  Many of these things should be self-tunable pretty
> easily, too...

I know this has been discussed before, but could a userspace daemon which
autotunes the tweakables do a better job wrt. to adapting the kernel
behaviour depending on the workload? Just like these days we have
irqbalance instead of a in-kernel "irq balancer". It's a alternative
worth of look at?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
