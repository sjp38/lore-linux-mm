Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBC4C8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 18:04:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e6-v6so3374358pge.5
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:04:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s16-v6si2918130plq.377.2018.09.25.15.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 15:04:08 -0700 (PDT)
Date: Tue, 25 Sep 2018 15:04:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2] mm, thp: always specify ineligible vmas as nh in
 smaps
Message-Id: <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
	<e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
	<alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
	<20180924195603.GJ18685@dhcp22.suse.cz>
	<20180924200258.GK18685@dhcp22.suse.cz>
	<0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
	<alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
	<20180925202959.GY18685@dhcp22.suse.cz>
	<alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, 25 Sep 2018 14:45:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> > > It is also used in 
> > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > this, and those tests now break.
> > 
> > This sounds like a bit of an abuse to me. It shows how an internal
> > implementation detail leaks out to the userspace which is something we
> > should try to avoid.
> > 
> 
> Well, it's already how this has worked for years before commit 
> 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> as long as you don't break userspace who relies on what is exported to it 
> and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> being backed by hugepages.

1860033237d4 was over a year ago so perhaps we don't need to be
too worried about restoring the old interface.  In which case
we have an opportunity to make improvements such as that suggested
by Michal?
