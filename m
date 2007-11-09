Date: Fri, 9 Nov 2007 12:13:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Message-Id: <20071109121332.7dd34777.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
References: <20071107004357.233417373@sgi.com>
	<20071107004710.862876902@sgi.com>
	<20071107191453.GC5080@shadowen.org>
	<200711080012.06752.ak@suse.de>
	<Pine.LNX.4.64.0711071639491.4640@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, apw@shadowen.org, linux-mm@kvack.org, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007 16:42:04 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 8 Nov 2007, Andi Kleen wrote:
> 
> > 
> > > We seem to be growing two different mechanisms here for 32bit and 64bit.
> > > This does seem a better option than that in 32bit CONFIG_4KSTACKS etc.
> > > IMO when these two merge we should consolidate on this version.
> > 
> > Best would be to not change it at all for 64bit for now.
> > 
> > We can worry about the 16k CPU systems when they appear, but shorter term
> > it would just lead to other crappy kernel code relying on large stacks when
> > it shouldn't.
> 
> Well we cannot really test these systems without these patches and when 
> they become officially available then its too late for merging.

It doesn't take many 2kb cpumasks to use up a lot of stack.

What else can we do?  Change all sites to do some dynamic allocation if
(NR_CPUS >= lots), I guess.

As for timing: we might as well merge it now so that 2.6.25 has at least a
chance of running on 16384-way.

otoh, I doubt if anyone will actually ship an NR_CPUS=16384 kernel, so it
isn't terribly pointful.

So I'm wobbly.  Could we please examine the alternatives before proceeding?
Is there any plan in anyone's mind to fix this problem in a better but
probably more intrusive fashion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
