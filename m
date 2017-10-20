Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA926B0069
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 11:23:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k15so5917353wrc.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:23:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 94sor537713wrf.42.2017.10.20.08.23.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 08:23:49 -0700 (PDT)
Date: Fri, 20 Oct 2017 17:23:46 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171020152346.f6tjybt7i5kzbhld@gmail.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <20171020081853.lmnvaiydxhy5c63t@gmail.com>
 <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> On Fri, Oct 20, 2017 at 08:18:53AM +0000, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > > On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A. Shutemov wrote:
> > > > On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> > > > > The first bunch of patches that prepare kernel to boot-time switching
> > > > > between paging modes.
> > > > > 
> > > > > Please review and consider applying.
> > > > 
> > > > Ping?
> > > 
> > > Ingo, is there anything I can do to get review easier for you?
> > 
> > Yeah, what is the conclusion on the sub-discussion of patch #2:
> > 
> >   [PATCH 2/6] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
> > 
> > ... do we want to skip it entirely and use the other 5 patches?
> 
> Yes, please. MAX_PHYSMEM_BITS not variable yet in this part of the series.
> 
> And I will post some version the patch in the next part, if it will be
> required.

Could we add TRULY_MAX_PHYSMEM_BITS (with a better name), to be used in places 
where memory footprint is not a big concern?

Or, could we keep MAX_PHYSMEM_BITS constant, and introduce a _different_ constant 
that is dynamic, and which could be used in the cases where the 5-level paging 
config causes too much memory footprint in the common 4-level paging case?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
