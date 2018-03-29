Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2076B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:20:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v21so2335047wmh.9
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:20:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si1189526wmc.150.2018.03.29.04.20.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Mar 2018 04:20:37 -0700 (PDT)
Date: Thu, 29 Mar 2018 13:20:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 06/14] mm/page_alloc: Propagate encryption KeyID
 through page allocator
Message-ID: <20180329112034.GE31039@dhcp22.suse.cz>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
 <20180328165540.648-7-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180328165540.648-7-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 28-03-18 19:55:32, Kirill A. Shutemov wrote:
> Modify several page allocation routines to pass down encryption KeyID to
> be used for the allocated page.
> 
> There are two basic use cases:
> 
>  - alloc_page_vma() use VMA's KeyID to allocate the page.
> 
>  - Page migration and NUMA balancing path use KeyID of original page as
>    KeyID for newly allocated page.

I am sorry but I am out of time to look closer but this just raised my
eyebrows. This looks like a no-go. The basic allocator has no business
in fancy stuff like a encryption key. If you need something like that
then just build a special allocator API on top. This looks like a no-go
to me.
-- 
Michal Hocko
SUSE Labs
