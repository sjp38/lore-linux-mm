Date: Wed, 08 Sep 2004 14:10:32 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <36100000.1094677832@flay>
In-Reply-To: <20040908215008.10a56e2b.diegocg@teleline.es>
References: <5860000.1094664673@flay><Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com> <20040908215008.10a56e2b.diegocg@teleline.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Diego Calleja <diegocg@teleline.es>, Rik van Riel <riel@redhat.com>
Cc: raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

>> > For HPC, maybe. For a fileserver, it might be far too little. That's the
>> > trouble ... it's all dependant on the workload. Personally, I'd prefer
>> > to get rid of manual tweakables (which are a pain in the ass in the field
>> > anyway), and try to have the kernel react to what the customer is doing.
>> 
>> Agreed.  Many of these things should be self-tunable pretty
>> easily, too...
> 
> I know this has been discussed before, but could a userspace daemon which
> autotunes the tweakables do a better job wrt. to adapting the kernel
> behaviour depending on the workload? Just like these days we have
> irqbalance instead of a in-kernel "irq balancer". It's a alternative
> worth of look at?

I really don't see any point in pushing the self-tuning of the kernel out
into userspace. What are you hoping to achieve?

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
