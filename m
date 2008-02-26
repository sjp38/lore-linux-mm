Date: Tue, 26 Feb 2008 11:38:09 +0200
Subject: Re: [ofa-general] Re: [patch 5/6] mmu_notifier: Support for
	drivers with revers maps (f.e. for XPmem)
Message-ID: <20080226093809.GF26611@minantech.com>
References: <20080215064859.384203497@sgi.com> <200802261711.33213.nickpiggin@yahoo.com.au> <20080226072137.GD26611@minantech.com> <200802261952.42567.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200802261952.42567.nickpiggin@yahoo.com.au>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, general@lists.openfabrics.org, akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2008 at 07:52:41PM +1100, Nick Piggin wrote:
> On Tuesday 26 February 2008 18:21, Gleb Natapov wrote:
> > On Tue, Feb 26, 2008 at 05:11:32PM +1100, Nick Piggin wrote:
> > > > You are missing one point here.  The MPI specifications that have
> > > > been out there for decades do not require the process use a library
> > > > for allocating the buffer.  I realize that is a horrible shortcoming,
> > > > but that is the world we live in.  Even if we could change that spec,
> > >
> > > Can you change the spec?
> >
> > Not really. It will break all existing codes.
> 
> I meant as in eg. submit changes to MPI-3
MPI spec tries to be backward compatible. And MPI-2 spec is 10 years
old, but MPI-1 is still in a wider use. HPC is moving fast in terms of HW
technology, but slow in terms of SW. Fortran is still hot there :)

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
