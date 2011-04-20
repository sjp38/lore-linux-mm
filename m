Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 54F618D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 15:25:45 -0400 (EDT)
Date: Wed, 20 Apr 2011 13:25:41 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
	expand_upwards
Message-ID: <20110420192540.GC31296@parisc-linux.org>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com> <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com> <20110420112020.GA31296@parisc-linux.org> <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com> <1303308938.2587.8.camel@mulgrave.site> <alpine.DEB.2.00.1104200943580.9266@router.home> <1303311779.2587.19.camel@mulgrave.site> <alpine.DEB.2.00.1104201018360.9266@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104201018360.9266@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, linux-arch@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Wed, Apr 20, 2011 at 10:22:04AM -0500, Christoph Lameter wrote:
> There is barely any testing going on at all of this since we have had this
> issue for more than 5 years and have not noticed it. The absence of bug
> reports therefore proves nothing. Code inspection of the VM shows
> that this is an issue that arises in multiple subsystems and that we have
> VM_BUG_ONs in the page allocator that should trigger for these situations.

So ... we've proven that people using these architectures use SLAB
instead of SLUB, don't enable CONFIG_DEBUG_VM and don't use hugepages
(not really a surprise ... nobody's running Oracle on these arches :-)

I don't think that qualifies as "barely any testing".  I think that's
"nobody developing the Linux MM uses one of these architectures".

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
