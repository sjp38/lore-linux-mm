Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <17948.29982.857777.776522@cargo.ozlabs.ibm.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
	 <1176180337.8061.21.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704102058420.18321@schroedinger.engr.sgi.com>
	 <1176265121.8061.66.camel@localhost.localdomain>
	 <17948.29982.857777.776522@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Wed, 11 Apr 2007 16:15:24 +1000
Message-Id: <1176272125.8061.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-11 at 15:41 +1000, Paul Mackerras wrote:
> Benjamin Herrenschmidt writes:
> 
> > > > For a 64K page size kernel, we have 3 level page tables and we use 3
> > > > caches: a PGD pages are 128 bytes (yeah, not big heh...), our pmd
> > > > pages are 32K (half a page) and PTE pages are PAGE_SIZE (64K).
> > > 
> > > Ok so use quicklists for the PTEs and slab for the rest? A PGD of only 128 
> > > bytes? Stuff one at the end of the mm_struct or the task struct? That way 
> > > you can avoid allocation overhead.
> > 
> > Yeah, maybe... I need to think about it a bit more. I might be able to
> > make the PMD a full page too.
> 
> There was a reason for making the PMD level map 256MB.  I'd have to
> remember what that was and make sure it didn't apply any more first...

For dynamic VSIDs....

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
