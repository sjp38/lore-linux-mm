Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2965E6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 04:18:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 78so326816wmb.15
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:18:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m198sor154802wmg.89.2017.10.20.01.18.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 01:18:56 -0700 (PDT)
Date: Fri, 20 Oct 2017 10:18:53 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171020081853.lmnvaiydxhy5c63t@gmail.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A. Shutemov wrote:
> > On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> > > The first bunch of patches that prepare kernel to boot-time switching
> > > between paging modes.
> > > 
> > > Please review and consider applying.
> > 
> > Ping?
> 
> Ingo, is there anything I can do to get review easier for you?

Yeah, what is the conclusion on the sub-discussion of patch #2:

  [PATCH 2/6] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS

... do we want to skip it entirely and use the other 5 patches?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
