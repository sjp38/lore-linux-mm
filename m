Date: Thu, 19 Feb 2004 19:16:33 +0000
From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219191633.GD31035@parcelfarce.linux.theplanet.co.uk>
References: <20040218140021.GB1269@us.ibm.com> <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org> <20040219123110.A22406@infradead.org> <20040219091129.GD1269@us.ibm.com> <20040219183210.GX14000@marowsky-bree.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040219183210.GX14000@marowsky-bree.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lars Marowsky-Bree <lmb@suse.de>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, torvalds@osd.org, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 19, 2004 at 07:32:10PM +0100, Lars Marowsky-Bree wrote:
> Only if we can settle this, we can answer this export question. If we
> want to allow them, the export is a perfectly reasonable thing to ask
> for. If not, we probably need to add a few more _GPL barriers.
> 
> A rule of thumb might be whether any code in the tree uses a given
> export, and if not, prune it. Anything which even we don't use or export
> across the user-land boundary certainly qualifies as a kernel interna.
> 
> Currently, no kernel module seems to use this export. So I'd think such
> a point could certainly be made.

I'm not sure.  I'm all for trimming the export list, but the real questions
are
	* does that export make sense?
	* does it impose extra restrictions on what we can do with core
code? (without breaking it, that is)
	* is it needed in the first place?  If it's redundant - to hell it
goes.

Note that majority of the exported symbols fail at least one of the above
and _that_ is why they should be killed.  Whether their users are GPL or
not doesn't matter - if they don't make sense, they must die, no matter
what b0rken code might be using them.

IMNSHO the questions above should be answered first and AFAICS they hadn't
been even discussed in that case.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
