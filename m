Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDEEF6B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 09:13:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l26so679251wmh.0
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 06:13:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor3261084edx.24.2018.03.29.06.13.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 06:13:44 -0700 (PDT)
Date: Thu, 29 Mar 2018 16:13:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180329131308.cq64n3dvnre2wcz5@node.shutemov.name>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
 <20180329112034.GE31039@dhcp22.suse.cz>
 <20180329123712.zlo6qmstj3zm5v27@node.shutemov.name>
 <20180329125227.GF31039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329125227.GF31039@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 29, 2018 at 02:52:27PM +0200, Michal Hocko wrote:
> On Thu 29-03-18 15:37:12, Kirill A. Shutemov wrote:
> > On Thu, Mar 29, 2018 at 01:20:34PM +0200, Michal Hocko wrote:
> > > On Wed 28-03-18 19:55:32, Kirill A. Shutemov wrote:
> > > > Modify several page allocation routines to pass down encryption KeyID to
> > > > be used for the allocated page.
> > > > 
> > > > There are two basic use cases:
> > > > 
> > > >  - alloc_page_vma() use VMA's KeyID to allocate the page.
> > > > 
> > > >  - Page migration and NUMA balancing path use KeyID of original page as
> > > >    KeyID for newly allocated page.
> > > 
> > > I am sorry but I am out of time to look closer but this just raised my
> > > eyebrows. This looks like a no-go. The basic allocator has no business
> > > in fancy stuff like a encryption key. If you need something like that
> > > then just build a special allocator API on top. This looks like a no-go
> > > to me.
> > 
> > The goal is to make memory encryption first class citizen in memory
> > management and not to invent parallel subsysustem (as we did with hugetlb).
> 
> How do you get a page_keyid for random kernel allocation?

Initial feature enabling only targets userspace anonymous memory, but we
can definately use the same technology in the future for kernel hardening
if we would choose so.

For anonymous memory, we can get KeyID from VMA or from other page
(migration case).

> > Making memory encryption integral part of Linux VM would involve handing
> > encrypted page everywhere we expect anonymous page to appear.
> 
> How many architectures will implement this feature?

I can't read the future.

I'm only aware about one architecture so far.

-- 
 Kirill A. Shutemov
