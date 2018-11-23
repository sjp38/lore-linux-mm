Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 583346B30F5
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 06:14:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so5664808edb.1
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 03:14:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s28-v6si15410717edd.159.2018.11.23.03.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 03:14:29 -0800 (PST)
Date: Fri, 23 Nov 2018 12:14:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Intel-gfx] [PATCH 1/3] mm: Check if mmu notifier callbacks are
 allowed to fail
Message-ID: <20181123111428.GF8625@dhcp22.suse.cz>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-2-daniel.vetter@ffwll.ch>
 <154290561362.11623.15299444358726283678@skylake-alporthouse-com>
 <20181123084934.GI4266@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123084934.GI4266@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>

On Fri 23-11-18 09:49:34, Daniel Vetter wrote:
> On Thu, Nov 22, 2018 at 04:53:34PM +0000, Chris Wilson wrote:
> > Quoting Daniel Vetter (2018-11-22 16:51:04)
> > > Just a bit of paranoia, since if we start pushing this deep into
> > > callchains it's hard to spot all places where an mmu notifier
> > > implementation might fail when it's not allowed to.
> > 
> > Most callers could handle the failure correctly. It looks like the
> > failure was not propagated for convenience.
> 
> I have no idea whether the mm is semantically ok if pte shootdown doesn't
> work for all sorts of strange reasons. From the commit that introduced the
> error code it souded like this was very much only ok in the limited case
> of an already killed process, in the oom killer path, where it's really
> only about trying to free any kind of memory. And where the process is
> gone already, so semantics of what exactly happens don't matter that much
> anymore.

Yes this was indeed the case. There is still the exit path which would
do the rest of the work so we are not leaving anything behind. 
-- 
Michal Hocko
SUSE Labs
