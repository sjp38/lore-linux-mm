Date: Thu, 1 May 2008 18:28:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] SLQB v2
In-Reply-To: <20080502012321.GE30768@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805011825420.13697@schroedinger.engr.sgi.com>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu>
 <20080501015418.GC15179@wotan.suse.de> <Pine.LNX.4.64.0805011226410.8738@schroedinger.engr.sgi.com>
 <20080502004325.GA30768@wotan.suse.de> <Pine.LNX.4.64.0805011813180.13527@schroedinger.engr.sgi.com>
 <20080502012321.GE30768@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2 May 2008, Nick Piggin wrote:

> But overloading struct page values happens in other places too. Putting
> everything into struct page is not scalable. We could also make kmalloc

Well lets at least attempt to catch the biggest users. Also makes code 
clearer if you f.e. use page->first_page instead of page->private for 
compound pages.

kmalloc is intended to return an arbitrary type. struct page has a defined 
format that needs to be respected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
