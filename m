From: Andi Kleen <ak@suse.de>
Subject: Re: Race in new page migration code?
Date: Mon, 16 Jan 2006 17:51:26 +0100
References: <20060114155517.GA30543@wotan.suse.de> <Pine.LNX.4.62.0601160807580.19672@schroedinger.engr.sgi.com> <Pine.LNX.4.61.0601161620060.9395@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0601161620060.9395@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601161751.26991.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 16 January 2006 17:28, Hugh Dickins wrote:
> On Mon, 16 Jan 2006, Christoph Lameter wrote:
> > On Mon, 16 Jan 2006, Hugh Dickins wrote:
> > 
> > > > It also applies to the policy compliance check.
> > > 
> > > Good point, I missed that: you've inadventently changed the behaviour
> > > of sys_mbind when it encounters a zero page from a disallowed node.
> > > Another reason to remove your PageReserved test.
> > 
> > The zero page always come from node zero on IA64. I think this is more the 
> > inadvertent fixing of a bug. The policy compliance check currently fails 
> > if an address range contains a zero page but node zero is not contained in 
> > the nodelist.
> 
> To me it sounds more like you introduced a bug than fixed one.
> If MPOL_MF_STRICT and the zero page is found but not in the nodelist
> demanded, then it's right to refuse, I'd say.  If Andi shares your
> view that the zero pages should be ignored, I won't argue; but we
> shouldn't change behaviour by mistake, without review or comment.

I agree with Christoph that the zero page should be ignored - old behaviour
was really a bug.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
