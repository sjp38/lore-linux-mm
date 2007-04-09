Date: Mon, 9 Apr 2007 11:48:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
Message-Id: <20070409114827.d3cbf705.akpm@linux-foundation.org>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon,  9 Apr 2007 11:25:09 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On x86_64 this cuts allocation overhead for page table pages down to
> a fraction (kernel compile / editing load. TSC based measurement
> of times spend in each function):
> 
> no quicklist
> 
> pte_alloc               1569048 4.3s(401ns/2.7us/179.7us)
> pmd_alloc                780988 2.1s(337ns/2.7us/86.1us)
> pud_alloc                780072 2.2s(424ns/2.8us/300.6us)
> pgd_alloc                260022 1s(920ns/4us/263.1us)
> 
> quicklist:
> 
> pte_alloc                452436 573.4ms(8ns/1.3us/121.1us)
> pmd_alloc                196204 174.5ms(7ns/889ns/46.1us)
> pud_alloc                195688 172.4ms(7ns/881ns/151.3us)
> pgd_alloc                 65228 9.8ms(8ns/150ns/6.1us)
> 
> pgd allocations are the most complex and there we see the most dramatic
> improvement (may be we can cut down the amount of pgds cached somewhat?).
> But even the pte allocations still see a doubling of performance.

Was there any observeable change in overall runtime?

What are the numbers in parentheses?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
