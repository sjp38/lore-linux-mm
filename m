Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 437066B0007
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:05:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36-v6so16140807edb.3
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 00:05:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q23-v6si5226579edg.419.2018.10.17.00.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 00:05:32 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:05:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181017070531.GC18839@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
 <20181004055842.GA22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
 <20181004094637.GG22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com>
 <20181009083326.GG8528@dhcp22.suse.cz>
 <20181015150325.GN18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 16-10-18 14:24:19, David Rientjes wrote:
> On Tue, 16 Oct 2018, Michal Hocko wrote:
> 
> > > I don't understand the point of extending smaps with yet another line.  
> > 
> > Because abusing a vma flag part is just wrong. What are you going to do
> > when a next bug report states that the flag is set even though no
> > userspace has set it and that leads to some malfunctioning? Can you rule
> > that out? Even your abuse of the flag is surprising so why others
> > wouldn't be?
> > 
> 
> The flag has taken on the meaning of "thp disabled for this vma", how it 
> is set is not the scope of the flag.  If a thp is explicitly disabled from 
> being eligible for thp, whether by madvise, prctl, or any future 
> mechanism, it should use VM_NOHUGEPAGE or show_smap_vma_flags() needs to 
> be modified.

No, this is not the meaning which is documented

nh  - no-huge page advise flag

and as far as I know it is only you who has complained so far.
 
> > As I've said there are two things. Exporting PR_SET_THP_DISABLE to
> > userspace so that a 3rd party process can query it. I've already
> > explained why that might be useful. If you really insist on having
> > a per-vma field then let's do it properly now. Are you going to agree on
> > that? If yes, I am willing to spend my time on that but I am not going
> > to bother if this will lead to "I want my vma field abuse anyway".
> 
> I think what you and I want is largely irrelevant :)  What's important is 
> that there are userspace implementations that query this today so 
> continuing to support it as the way to determine if a vma has been thp 
> disabled doesn't seem problematic and guarantees that userspace doesn't 
> break.

Do you know of any other userspace except your usecase? Is there
anything fundamental that would prevent a proper API adoption for you?

-- 
Michal Hocko
SUSE Labs
