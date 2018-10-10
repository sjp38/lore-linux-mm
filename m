Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBA836B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 14:52:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e7-v6so3641899edb.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:52:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2-v6si1783703ejg.230.2018.10.10.11.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 11:52:45 -0700 (PDT)
Date: Wed, 10 Oct 2018 20:52:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Message-ID: <20181010185242.GP5873@dhcp22.suse.cz>
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
 <20181010095838.GG5873@dhcp22.suse.cz>
 <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com>
 <20181010172451.GK5873@dhcp22.suse.cz>
 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, yi.z.zhang@linux.intel.com

On Wed 10-10-18 10:39:01, Alexander Duyck wrote:
> On 10/10/2018 10:24 AM, Michal Hocko wrote:
[...]
> > I thought I have already made it clear that these zone device hacks are
> > not acceptable to the generic hotplug code. If the current reserve bit
> > handling is not correct then give us a specific reason for that and we
> > can start thinking about the proper fix.
> 
> I might have misunderstood your earlier comment then. I thought you were
> saying that we shouldn't bother with setting the reserved bit. Now it sounds
> like you were thinking more along the lines of what I was here in my comment
> where I thought the bit should be cleared later in some code specifically
> related to DAX when it is exposing it for use to userspace or KVM.

It seems I managed to confuse myself completely. Sorry, it's been a long
day and I am sick so the brain doesn't work all that well. I will get
back to this tomorrow or on Friday with a fresh brain.

My recollection was that we do clear the reserved bit in
move_pfn_range_to_zone and we indeed do in __init_single_page. But then
we set the bit back right afterwards. This seems to be the case since
d0dc12e86b319 which reorganized the code. I have to study this some more
obviously.

-- 
Michal Hocko
SUSE Labs
