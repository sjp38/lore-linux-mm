Date: Tue, 5 Aug 2008 04:05:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 3/3] xfs: use new vmap API
Message-ID: <20080805020539.GA15075@wotan.suse.de>
References: <20080728123438.GA13926@wotan.suse.de> <20080728123703.GC13926@wotan.suse.de> <4896A197.3090004@sgi.com> <200808042057.20607.nickpiggin@yahoo.com.au> <4897B05A.7040002@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4897B05A.7040002@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Assuming patch 1 gets merged upstream, I think Andrew would normally send
off 2 and 3 to the XFS maintainers at that point (ie. when its prerequisites
are upstream) for you to merge. 

On Tue, Aug 05, 2008 at 11:43:54AM +1000, Lachlan McIlroy wrote:
> Okay.  When the time comes will you push the XFS changes to mainline
> or would you like us to?
> 
> Nick Piggin wrote:
> >Thanks for taking a look. I'll send them over to -mm with patch 1,
> >then, for some testing.
> >
> >On Monday 04 August 2008 16:28, Lachlan McIlroy wrote:
> >>Looks good to me.
> >>
> >>Nick Piggin wrote:
> >>>Implement XFS's large buffer support with the new vmap APIs. See the vmap
> >>>rewrite patch for some numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
