Date: Tue, 10 May 2005 21:07:09 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
Message-ID: <20050510190708.GA32007@devserv.devel.redhat.com>
References: <20050509142651.1d3ae91e.akpm@osdl.org> <200505101535.j4AFZtg23695@unix-os.sc.intel.com> <20050510115818.0828f5d1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050510115818.0828f5d1.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, wwc@rentec.com, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 10, 2005 at 11:58:18AM -0700, Andrew Morton wrote:
> "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
> >
> > Andrew Morton wrote on Monday, May 09, 2005 2:27 PM
> > > Possibly for the 2.6.12 release the safest approach would be to just
> > > disable the free area cache while we think about it.
> > 
> > I hope people are not thinking permanently kill the free area cache
> > algorithm.  It is known to give a large percentage of performance gain
> > on specweb SSL benchmark.  I think it gives 4-5% gain from free area
> > cache algorithm.
> 
> It also makes previously-working workloads completely *fail*.

the balance between correctness and performance ;)

the patch to keep track of basically the below-gap-size will fix the
correctness side I suppose, however I'm not sure I'm thrilled by the
inherent complexity that is beeing added. More to track means more
complexity and fragility. 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
