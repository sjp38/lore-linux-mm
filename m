Date: Mon, 16 Jan 2006 16:28:03 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <Pine.LNX.4.62.0601160807580.19672@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0601161620060.9395@goblin.wat.veritas.com>
References: <20060114155517.GA30543@wotan.suse.de>
 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
 <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601151053420.4500@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0601152251080.17034@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601161143190.7123@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0601160739360.19188@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601161555130.9134@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0601160807580.19672@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jan 2006, Christoph Lameter wrote:
> On Mon, 16 Jan 2006, Hugh Dickins wrote:
> 
> > > It also applies to the policy compliance check.
> > 
> > Good point, I missed that: you've inadventently changed the behaviour
> > of sys_mbind when it encounters a zero page from a disallowed node.
> > Another reason to remove your PageReserved test.
> 
> The zero page always come from node zero on IA64. I think this is more the 
> inadvertent fixing of a bug. The policy compliance check currently fails 
> if an address range contains a zero page but node zero is not contained in 
> the nodelist.

To me it sounds more like you introduced a bug than fixed one.
If MPOL_MF_STRICT and the zero page is found but not in the nodelist
demanded, then it's right to refuse, I'd say.  If Andi shares your
view that the zero pages should be ignored, I won't argue; but we
shouldn't change behaviour by mistake, without review or comment.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
