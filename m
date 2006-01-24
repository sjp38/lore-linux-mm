Subject: Re: [PATCH/RFC] Shared page tables
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <200601240238.29781.ak@suse.de>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
	 <200601240210.04337.ak@suse.de> <20060124012331.GK1008@kvack.org>
	 <200601240238.29781.ak@suse.de>
Content-Type: text/plain
Date: Tue, 24 Jan 2006 08:08:16 +0100
Message-Id: <1138086496.2977.22.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Ray Bryant <raybry@mpdtxmail.amd.com>, Dave McCracken <dmccr@us.ibm.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-24 at 02:38 +0100, Andi Kleen wrote:
> On Tuesday 24 January 2006 02:23, Benjamin LaHaise wrote:
> > On Tue, Jan 24, 2006 at 02:10:03AM +0100, Andi Kleen wrote:
> > > The randomization is not for cache coloring, but for security purposes
> > > (except for the old very small stack randomization that was used
> > > to avoid conflicts on HyperThreaded CPUs). I would be surprised if the
> > > mmap made much difference because it's page aligned and at least
> > > on x86 the L2 and larger caches are usually PI.
> > 
> > Actually, does this even affect executable segments?  Iirc, prelinking 
> > already results in executables being mapped at the same physical offset 
> > across binaries in a given system.  An strace seems to confirm that.
> 
> Shared libraries should be affected. And prelink is not always used.

without prelink you have almost no sharing of the exact same locations,
since each binary will link to different libs and in different orders,
so any sharing you get is purely an accident (with glibc being maybe an
exception since everything will link that first). This
sharing-of-code-pagetables seems to really depend on prelink to work
well, regardless of randomization

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
