Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 797E96B2FE0
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:44:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w2so5296656edc.13
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:44:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge19-v6si21211438ejb.169.2018.11.23.04.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:43:59 -0800 (PST)
Date: Fri, 23 Nov 2018 13:43:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20181123124358.GJ8625@dhcp22.suse.cz>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
 <20181123111557.GG8625@dhcp22.suse.cz>
 <20181123123057.GK4266@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123123057.GK4266@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri 23-11-18 13:30:57, Daniel Vetter wrote:
> On Fri, Nov 23, 2018 at 12:15:57PM +0100, Michal Hocko wrote:
> > On Thu 22-11-18 17:51:04, Daniel Vetter wrote:
> > > Just a bit of paranoia, since if we start pushing this deep into
> > > callchains it's hard to spot all places where an mmu notifier
> > > implementation might fail when it's not allowed to.
> > 
> > What does WARN give you more than the existing pr_info? Is really
> > backtrace that interesting?
> 
> Automated tools have to ignore everything at info level (there's too much
> of that). I guess I could do something like
> 
> if (blockable)
> 	pr_warn(...)
> else
> 	pr_info(...)
> 
> WARN() is simply my goto tool for getting something at warning level
> dumped into dmesg. But I think the pr_warn with the callback function
> should be enough indeed.

I wouldn't mind s@pr_info@pr_warn@
 
> If you wonder where all the info level stuff happens that we have to
> ignore: suspend/resume is a primary culprit (fairly important for
> gfx/desktops), but there's a bunch of other places. Even if we ignore
> everything at info and below we still need filters because some drivers
> are a bit too trigger-happy (i915 definitely included I guess, so everyone
> contributes to this problem).

Thanks for the clarification.
-- 
Michal Hocko
SUSE Labs
