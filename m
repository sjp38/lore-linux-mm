Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D87B6B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 07:43:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 11so8613166wrb.10
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:43:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v23sor59374eda.27.2017.10.24.04.43.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 04:43:13 -0700 (PDT)
Date: Tue, 24 Oct 2017 14:43:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171024114311.zmzhubtwpnegcvid@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <D692A598-D2C7-433A-84E6-D310299935CC@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D692A598-D2C7-433A-84E6-D310299935CC@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 24, 2017 at 01:32:51PM +0200, hpa@zytor.com wrote:
> On October 17, 2017 5:42:41 PM GMT+02:00, "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A. Shutemov wrote:
> >> On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> >> > The first bunch of patches that prepare kernel to boot-time
> >switching
> >> > between paging modes.
> >> > 
> >> > Please review and consider applying.
> >> 
> >> Ping?
> >
> >Ingo, is there anything I can do to get review easier for you?
> >
> >I hoped to get boot-time switching code into v4.15...
> 
> One issue that has come up with this is what happens if the kernel is
> loaded above 4 GB and we need to switch page table mode.  In that case
> we need enough memory below the 4 GB point to hold a root page table
> (since we can't write the upper half of cr3 outside of 64-bit mode) and
> a handful of instructions.
> 
> We have no real way to know for sure what memory is safe without parsing
> all the memory maps and map out all the data structures that The
> bootloader has left for the kernel.  I'm thinking that the best way to
> deal with this is to add an entry in setup_data to provide a pointers,
> with the kernel header specifying a necessary size and alignment.

I would appreciate your feedback on my take on this:

http://lkml.kernel.org/r/20171020195934.32108-1-kirill.shutemov@linux.intel.com

I don't change boot protocol, but trying to guess the safe spot in the way
similar to what we do for realmode trampoline.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
