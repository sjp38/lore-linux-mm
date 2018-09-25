Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6398E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 01:50:25 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k16-v6so10405749ede.6
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 22:50:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y37-v6si4832619edd.10.2018.09.24.22.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 22:50:24 -0700 (PDT)
Date: Tue, 25 Sep 2018 07:50:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in smaps
Message-ID: <20180925055022.GL18685@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
 <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
 <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Mon 24-09-18 22:43:49, Vlastimil Babka wrote:
> On 9/24/18 10:02 PM, Michal Hocko wrote:
> > On Mon 24-09-18 21:56:03, Michal Hocko wrote:
[...]
> >> That being said, I do not object to the patch, I am just trying to
> >> understand what is the intended usage for the flag that does try to say
> >> more than the madvise status.
> > 
> > And moreover, how is the PR_SET_THP_DISABLE any different from the
> > global THP disabled case. Do we want to set all vmas to nh as well?
> 
> Probably not. It's easy to check the global status, but is it possible
> to query for the prctl flags of a process?

Dunno but I suspect there is no way to check for this.

> We are looking at process or
> even vma-specific flags here. If the prctl was historically implemented
> via VM_NOHUGEPAGE and thus reported as such in smaps, it makes sense to
> do so even with the MMF_ flag IMHO?

Yes if this breaks some userspace which relied on the previous behavior.
But if nothing really broke then I guess it would be better to have the
semantic as clear as possible. Go and check the global status to make
the whole picture doesn't look very sound to me. On the other hand this
VMA has a madvise flag on it sounds quite clear and you know what to
expect at least. Sure the hint might be ignored in the end but well,
these are hints they do not guarantee anything after all.
-- 
Michal Hocko
SUSE Labs
