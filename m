Date: Sun, 15 Jan 2006 10:58:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0601151053420.4500@goblin.wat.veritas.com>
References: <20060114155517.GA30543@wotan.suse.de>
 <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
 <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jan 2006, Christoph Lameter wrote:
> 
> Also remove the WARN_ON since its now even possible that other actions of 
> the VM move the pages into the LRU lists while we scan for pages to
> migrate.

Good.  And whether it's your or Nick's patch that goes in, please also
remove that PageReserved test which you recently put in check_pte_range.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
