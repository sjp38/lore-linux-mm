Date: Tue, 10 May 2005 12:43:57 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared
 to
Message-Id: <20050510124357.2a7d2f9b.akpm@osdl.org>
In-Reply-To: <200505101934.j4AJYfg26483@unix-os.sc.intel.com>
References: <20050510115818.0828f5d1.akpm@osdl.org>
	<200505101934.j4AJYfg26483@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: wwc@rentec.com, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>
> Andrew Morton wrote Tuesday, May 10, 2005 11:58 AM
> > "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> > > Andrew Morton wrote on Monday, May 09, 2005 2:27 PM
> > > > Possibly for the 2.6.12 release the safest approach would be to just
> > > > disable the free area cache while we think about it.
> > > 
> > > I hope people are not thinking permanently kill the free area cache
> > > algorithm.  It is known to give a large percentage of performance gain
> > > on specweb SSL benchmark.  I think it gives 4-5% gain from free area
> > > cache algorithm.
> > 
> > It also makes previously-working workloads completely *fail*.
> 
> I agree that functionality over rule most of everything else.  Though, I
> do want to bring to your attention on how much performance regression we
> will see if the free area cache is completely disabled.  I rather make
> noise now instead of a couple month down the road :-)

Well we allegedly have a patch from Wolfgang which fixes things up, but our
talk-to-testing ratio seems to be infinite.

This is pretty serious, guys.  Could someone please find the time to work
on it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
