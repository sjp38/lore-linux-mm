From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Date: Mon, 8 Sep 2008 15:52:49 +1000
References: <20080905215452.GF11692@us.ibm.com> <20080906153855.7260.E1E9C6FF@jp.fujitsu.com> <20080906085320.GE18288@one.firstfloor.org>
In-Reply-To: <20080906085320.GE18288@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809081552.50126.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Saturday 06 September 2008 18:53, Andi Kleen wrote:
> On Sat, Sep 06, 2008 at 04:06:38PM +0900, Yasunori Goto wrote:
> > > not.
> > >
> > > This means I don't see a real use case for this feature.
> >
> > I don't think its driver is almighty.
> > IIRC, balloon driver can be cause of fragmentation for 24-7 system.
>
> Sure the balloon driver can be likely improved too, it's just
> that I don't think a balloon driver should call into the function
> the original patch in the series hooked up.
>
> > In addition, I have heard that memory hotplug would be useful for
> > reducing of power consumption of DIMM.
>
> It's unclear that memory hotplug is the right model for DIMM power
> management. The problem is that DIMMs are interleaved, so you again have to
> completely free a quite large area. It's not much easier than node hotplug.
>
> > I have to admit that memory hotplug has many issues, but I would like to
>
> Let's call it "node" or "hardware" memory hot unplug, not that
> anyone confuses it with the easier VM based hot unplug or the really
> easy hotadd.
>
> > solve them step by step.
>
> The question is if they are even solvable in a useful way.
> I'm not sure it's that useful to start and then find out
> that it doesn't work anyways.

You use non-linear mappings for the kernel, so that kernel data is
not tied to a specific physical address. AFAIK, that is the only way
to really do it completely (like the fragmentation problem).

Of course, I don't think that would be a good idea to do that in the
forseeable future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
