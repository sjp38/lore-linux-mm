Date: Thu, 30 Aug 2007 01:38:03 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC:PATCH 00/07] VM File Tails
Message-ID: <20070829233802.GC29635@lazybastard.org>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com> <20070829213154.GB29635@lazybastard.org> <1188423942.6529.74.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1188423942.6529.74.camel@norville.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 August 2007 21:45:42 +0000, Dave Kleikamp wrote:
> On Wed, 2007-08-29 at 23:31 +0200, JA?rn Engel wrote:
> > On Wed, 29 August 2007 16:53:25 -0400, Dave Kleikamp wrote:
> > >
> > > - benchmark!
> > 
> > I'd love to know how much difference this makes.  Basically four
> > numbers:
> > - number of address spaces
> > - bytes allocated for file tails
> > - number of pages allocated for non-tail storage
> > - number of pages allocated for tail storage
> 
> The last one may be tricky, since I'm allocating the tails using
> kmalloc.  The data will be interspersed with other kmalloc'ed data.  We
> could keep track of the bytes, and the number of tails, but we wouldn't
> know exactly how the tail bytes correspond to the number of pages needed
> to store them.

Sorry, I should have been more precise.  Under some circumstances like
mmap() you have to allocate a page and copy the tail to that page.  My
last point was about the number of such pages, not the number of pages
buried in slab caches.

Iiuc your current implementation would keep the kmalloc()-allocated tail
in the address space and _additionally_ have a full page for the same
data.  So the patches aimed to save memory may actually waste memory and
depending on circumstances may waste more than they save.  Or did I
misinterpret something?

JA?rn

-- 
It is better to die of hunger having lived without grief and fear,
than to live with a troubled spirit amid abundance.
-- Epictetus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
