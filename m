Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60E1E6B0278
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:24:32 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w191so773889wme.8
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:24:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor13247506edf.47.2017.11.15.06.24.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 06:24:29 -0800 (PST)
Date: Wed, 15 Nov 2017 17:24:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] x86/mm: Do not allow non-MAP_FIXED mapping across
 DEFAULT_MAP_WINDOW border
Message-ID: <20171115142427.75vwlpntdnsbmjqp@node.shutemov.name>
References: <20171114202102.crpgiwgv2lu5aboq@node.shutemov.name>
 <alpine.DEB.2.20.1711142131010.2221@nanos>
 <20171114222718.76w4lmclf6wasbl3@node.shutemov.name>
 <alpine.DEB.2.20.1711142354520.2221@nanos>
 <20171115112702.e2m66wons37imtcj@node.shutemov.name>
 <alpine.DEB.2.20.1711151238500.1805@nanos>
 <20171115121042.dt2us5fsuqmepx4i@node.shutemov.name>
 <20171115140426.bgvcd3bmegqadm5q@node.shutemov.name>
 <20171115141326.xzsbkycdwq4vafxf@node.shutemov.name>
 <alpine.DEB.2.20.1711151521010.1805@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711151521010.1805@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 03:23:32PM +0100, Thomas Gleixner wrote:
> On Wed, 15 Nov 2017, Kirill A. Shutemov wrote:
> > On Wed, Nov 15, 2017 at 05:04:26PM +0300, Kirill A. Shutemov wrote:
> >  	/* requesting a specific address */
> >  	if (addr) {
> > -		addr = PAGE_ALIGN(addr);
> > +		addr &= PAGE_MASK;
> >  		if (!mmap_address_hint_valid(addr, len))
> >  			goto get_unmapped_area;
> >  
> > diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> > index 92db903c3dad..00b296617ca4 100644
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -166,7 +166,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> >  	}
> >  
> >  	if (addr) {
> > -		addr = ALIGN(addr, huge_page_size(h));
> > +		addr &= huge_page_mask(h);
> >  		if (!mmap_address_hint_valid(addr, len))
> >  			goto get_unmapped_area;
> 
> That should work. Care to pickup my variant, make the fixups and resend
> along with the selftest which covers both normal and huge mappings?

Sure.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
