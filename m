Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 190946B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:25:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c28-v6so8302948pfe.4
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:25:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j35-v6sor2970196pgm.84.2018.10.15.15.25.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 15:25:17 -0700 (PDT)
Date: Mon, 15 Oct 2018 15:25:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181015150325.GN18839@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
References: <20180926060624.GA18685@dhcp22.suse.cz> <20181002112851.GP18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com> <20181003073640.GF18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
 <20181004055842.GA22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com> <20181004094637.GG22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com> <20181009083326.GG8528@dhcp22.suse.cz>
 <20181015150325.GN18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Mon, 15 Oct 2018, Michal Hocko wrote:

> > > No, because the offending commit actually changed the precedence itself: 
> > > PR_SET_THP_DISABLE used to be honored for future mappings and the commit 
> > > changed that for all current mappings.
> > 
> > Which is the actual and the full point of the fix as described in the
> > changelog. The original implementation was poor and inconsistent.
> > 
> > > So as a result of the commit 
> > > itself we would have had to change the documentation and userspace can't 
> > > be expected to keep up with yet a fourth variable: kernel version.  It 
> > > really needs to be simpler, just a per-mapping specifier.
> > 
> > As I've said, if you really need a per-vma granularity then make it a
> > dedicated line in the output with a clear semantic. Do not make VMA
> > flags even more confusing.
> 
> Can we settle with something please?

I don't understand the point of extending smaps with yet another line.  
The only way for a different process to determine if a single vma from 
another process is thp disabled is by the "nh" flag, so it is reasonable 
that userspace reads this.  My patch fixes that.  If smaps is extended 
with another line per your patch, it doesn't change the fact that previous 
binaries are built to check for "nh" so it does not deprecate that.  
("THP_Enabled" is also ambiguous since it only refers to prctl and not the 
default thp setting or madvise.)
