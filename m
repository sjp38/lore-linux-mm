Date: Thu, 8 May 2008 19:58:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
In-Reply-To: <1210272164.7905.66.camel@nimitz.home.sr71.net>
Message-ID: <Pine.LNX.4.64.0805081951570.21297@blonde.site>
References: <Pine.LNX.4.64.0805062043580.11647@blonde.site>
 <20080506202201.GB12654@escobedo.amd.com>  <1210106579.4747.51.camel@nimitz.home.sr71.net>
  <20080508143453.GE12654@escobedo.amd.com>  <1210258350.7905.45.camel@nimitz.home.sr71.net>
  <20080508151145.GG12654@escobedo.amd.com>  <1210261882.7905.49.camel@nimitz.home.sr71.net>
  <20080508161925.GH12654@escobedo.amd.com>  <20080508163352.GN23990@us.ibm.com>
  <20080508165111.GI12654@escobedo.amd.com>  <20080508171657.GO23990@us.ibm.com>
 <1210272164.7905.66.camel@nimitz.home.sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Hans Rosenfeld <hans.rosenfeld@amd.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 8 May 2008, Dave Hansen wrote:
> 
> But, I do think it is absolutely insane to have pmd_clear_bad() going
> after perfectly good hugetlb pmds.  The way it is set up now, people are
> bound to miss the hugetlb pages because just about every single
> pagetable walk has to be specially coded to handle or avoid them.  We
> obviously missed it, here, and we had two good examples in the same
> file! :)

Like it or not, the pgd/pud/pmd/pte hierarchy cannot be assumed once
you're amongst hugepages.  What happens varies from architecture to
architecture.  Perhaps the hugepage specialists could look at what
in fact the different architectures we know today are doing, and
come up with a better abstraction to encompass them all.  But it's
simply wrong for a "generic" pagewalker to be going blindly in there.

Two good examples in the same file??

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
