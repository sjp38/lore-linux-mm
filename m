Date: Mon, 16 Jan 2006 07:47:50 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <Pine.LNX.4.61.0601161143190.7123@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0601160739360.19188@schroedinger.engr.sgi.com>
References: <20060114155517.GA30543@wotan.suse.de>
 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
 <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601151053420.4500@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0601152251080.17034@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0601161143190.7123@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jan 2006, Hugh Dickins wrote:

> Indeed they are, at present and quite likely into posterity.  But
> they're not a common case here, and migrate_page_add now handles them
> silently, so why bother to complicate it with an unnecessary check?

check_range also is used for statistics and for checking if a range is 
policy compliant. Without that check zeropages may be counted or flagged 
as not on the right node with MPOL_MF_STRICT.

For migrate_page_add this has now simply become an optimization since
there is no WARN_ON occurring anymore.

> Or have you found the zero page mapcount distorting get_stats stats?
> If that's an issue, then better add a commented test for it there.

It also applies to the policy compliance check.

> Hmm, that battery of unusual tests at the start of migrate_page_add
> is odd: the tests don't quite match the comment, and it isn't clear
> what reasoning lies behind the comment anywa

Hmm.... Maybe better clean up the thing a bit. Will do that when I get 
back to work next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
