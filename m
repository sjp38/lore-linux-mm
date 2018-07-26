Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFBB46B000A
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 10:25:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f13-v6so880473edr.10
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 07:25:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i14-v6si1657857ede.243.2018.07.26.07.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 07:25:06 -0700 (PDT)
Date: Thu, 26 Jul 2018 16:25:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv5 05/19] mm/page_alloc: Handle allocation for encrypted
 memory
Message-ID: <20180726142504.GN28386@dhcp22.suse.cz>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-6-kirill.shutemov@linux.intel.com>
 <95ce19cb-332c-44f5-b3a1-6cfebd870127@intel.com>
 <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 19-07-18 11:27:24, Kirill A. Shutemov wrote:
> On Wed, Jul 18, 2018 at 04:03:53PM -0700, Dave Hansen wrote:
> > I asked about this before and it still isn't covered in the description:
> > You were specifically asked (maybe in person at LSF/MM?) not to modify
> > allocator to pass the keyid around.  Please specifically mention how
> > this design addresses that feedback in the patch description.
> > 
> > You were told, "don't change the core allocator", so I think you just
> > added new functions that wrap the core allocator and called them from
> > the majority of sites that call into the core allocator.  Personally, I
> > think that misses the point of the original request.
> > 
> > Do I have a better way?  Nope, not really.
> 
> +Michal.
> 
> IIRC, Michal was not happy that I propagate the KeyID to very core
> allcoator and we've talked about wrappers around existing APIs as a better
> solution.
> 
> Michal, is it correct?

Yes that is the case. I haven't seen this series and unlikely will get
to it in upcoming days though so I cannot comment much more
unfortunately.
-- 
Michal Hocko
SUSE Labs
