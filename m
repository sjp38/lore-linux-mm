Subject: Re: [discuss] [PATCH] Inconsistent mmap()/mremap() flags
From: Thayne Harbaugh <thayne@c2.net>
Reply-To: thayne@c2.net
In-Reply-To: <Pine.LNX.4.64.0710021505400.2156@blonde.wat.veritas.com>
References: <1190958393.5128.85.camel@phantasm.home.enterpriseandprosperity.com>
	 <1191308772.5200.66.camel@phantasm.home.enterpriseandprosperity.com>
	 <Pine.LNX.4.64.0710021304230.26719@blonde.wat.veritas.com>
	 <200710021545.32556.ak@suse.de>
	 <Pine.LNX.4.64.0710021505400.2156@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Tue, 02 Oct 2007 09:21:26 -0600
Message-Id: <1191338486.5200.71.camel@phantasm.home.enterpriseandprosperity.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andi Kleen <ak@suse.de>, discuss@x86-64.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-02 at 15:16 +0100, Hugh Dickins wrote:
> On Tue, 2 Oct 2007, Andi Kleen wrote:
> > 
> > > First call mmap with a low hint address, the new size you'll be wanting
> > > from the mremap, PROT_NONE, MAP_ANONYMOUS, -1, 0.  Then call mremap with
> > > old address, old size, new size, MREMAP_MAYMOVE|MREMAP_FIXED, and new
> > > address as returned by the preparatory mmap.
> > 
> > That's racy unfortunately in a multithreaded process. They would need to loop.
> 
> Perhaps.  Though I don't see what your loop would be doing;
> and the mapping established by the first thread would only
> be vulnerable to another thread if that were really set on
> interfering (an un-FIXED mmap by another thread will keep
> away from the area assigned to the first).
> 
> Certainly a two-stage procedure has to be weaker than one stage,
> but it is just how MAP_FIXED is normally used (isn't it?): first
> stake out an arena for all that's needed without MAP_FIXED, then
> fit into it the actual mappings required using MAP_FIXED.  Blind
> use of MAP_FIXED is always in danger of unmapping something vital.
> 
> But whether the two-stage procedure is good enough for Thayne's
> purpose, he'll have to judge for himself.

I think my eyes have been opened enough so that I can get things to work
- it's certainly better in many respects than using MAP_32BIT with its
many limitations.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
