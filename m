Date: Wed, 19 Sep 2007 11:57:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] oom: only kill tasks that share zones with zonelist
In-Reply-To: <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709191156480.2241@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, David Rientjes wrote:

> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			unsigned long pfn;
> +			struct zone *zone;
> +
> +			pfn = PFN_DOWN(vma->vm_start);
> +			zone = page_zone(pfn_to_page(pfn));

This seems to assume that all pages in a vma are in the same zone? That is 
not the case. On a NUMA system pages may be allocated round robin. Meaning 
lots of zones are used that this approach does not catch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
