Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6B26B0007
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 08:52:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so4287954pfp.1
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 05:52:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si4606536pff.24.2018.03.29.05.52.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Mar 2018 05:52:31 -0700 (PDT)
Date: Thu, 29 Mar 2018 14:52:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180329125227.GF31039@dhcp22.suse.cz>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
 <20180329112034.GE31039@dhcp22.suse.cz>
 <20180329123712.zlo6qmstj3zm5v27@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329123712.zlo6qmstj3zm5v27@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 29-03-18 15:37:12, Kirill A. Shutemov wrote:
> On Thu, Mar 29, 2018 at 01:20:34PM +0200, Michal Hocko wrote:
> > On Wed 28-03-18 19:55:32, Kirill A. Shutemov wrote:
> > > Modify several page allocation routines to pass down encryption KeyID to
> > > be used for the allocated page.
> > > 
> > > There are two basic use cases:
> > > 
> > >  - alloc_page_vma() use VMA's KeyID to allocate the page.
> > > 
> > >  - Page migration and NUMA balancing path use KeyID of original page as
> > >    KeyID for newly allocated page.
> > 
> > I am sorry but I am out of time to look closer but this just raised my
> > eyebrows. This looks like a no-go. The basic allocator has no business
> > in fancy stuff like a encryption key. If you need something like that
> > then just build a special allocator API on top. This looks like a no-go
> > to me.
> 
> The goal is to make memory encryption first class citizen in memory
> management and not to invent parallel subsysustem (as we did with hugetlb).

How do you get a page_keyid for random kernel allocation?
 
> Making memory encryption integral part of Linux VM would involve handing
> encrypted page everywhere we expect anonymous page to appear.

How many architectures will implement this feature?
-- 
Michal Hocko
SUSE Labs
