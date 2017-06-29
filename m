Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1A236B02F4
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:07:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c81so2695048wmd.10
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:07:01 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id v2si4274144wrb.15.2017.06.29.08.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:07:00 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id y5so3109560wmh.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:07:00 -0700 (PDT)
Date: Thu, 29 Jun 2017 18:06:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/5] Last bits for initial 5-level paging enabling
Message-ID: <20170629150657.urgapbzmf3jy6jgp@node.shutemov.name>
References: <20170622122608.80435-1-kirill.shutemov@linux.intel.com>
 <20170623090601.njsmucxdy4rev6zw@gmail.com>
 <20170623144915.4d6esghvicnczuaj@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623144915.4d6esghvicnczuaj@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 23, 2017 at 05:49:15PM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 23, 2017 at 11:06:01AM +0200, Ingo Molnar wrote:
> > 
> > * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > As Ingo requested I've split and updated last two patches for my previous
> > > patchset.
> > > 
> > > Please review and consider applying.
> > > 
> > > Kirill A. Shutemov (5):
> > >   x86: Enable 5-level paging support
> > >   x86/mm: Rename tasksize_32bit/64bit to task_size_32bit/64bit
> > >   x86/mpx: Do not allow MPX if we have mappings above 47-bit
> > >   x86/mm: Prepare to expose larger address space to userspace
> > >   x86/mm: Allow userspace have mapping above 47-bit
> > 
> > Ok, looks pretty neat now.
> > 
> > Can I apply them in this order cleanly, without breaking bisection:
> > 
> > >   x86/mm: Rename tasksize_32bit/64bit to task_size_32bit/64bit
> > >   x86/mpx: Do not allow MPX if we have mappings above 47-bit
> > >   x86/mm: Prepare to expose larger address space to userspace
> > >   x86/mm: Allow userspace have mapping above 47-bit
> > >   x86: Enable 5-level paging support
> > 
> > ?
> > 
> > I.e. I'd like to move the first patch last.
> > 
> > The reason is that we should first get all quirks and assumptions fixed, all 
> > facilities implemented - and only then enable 5-level paging as a final step which 
> > produces a well working kernel.
> > 
> > (This should also make it slightly easier to analyze any potential regressions in 
> > earlier patches.)
> 
> Just checked bisectability with this order on allmodconfig -- works fine.

Ingo, if there's no objections, can we get these applied?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
