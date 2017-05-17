Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74BEF6B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:23:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z88so994756wrc.9
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:23:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e135si1941920wmd.44.2017.05.17.02.23.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 02:23:48 -0700 (PDT)
Date: Wed, 17 May 2017 11:23:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] drm: replace drm_[cm]alloc* by kvmalloc alternatives
Message-ID: <20170517092344.GI18247@dhcp22.suse.cz>
References: <20170517065509.18659-1-mhocko@kernel.org>
 <20170517073809.GJ26693@nuc-i3427.alporthouse.com>
 <20170517090350.GG18247@dhcp22.suse.cz>
 <20170517091241.GL26693@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517091241.GL26693@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Wed 17-05-17 10:12:41, Chris Wilson wrote:
> On Wed, May 17, 2017 at 11:03:50AM +0200, Michal Hocko wrote:
[...]
> > +static inline bool alloc_array_check(size_t n, size_t size)
> > +{
> > +	if (size != 0 && n > SIZE_MAX / size)
> > +		return false;
> > +	return true;
> 
> Just return size == 0 || n <= SIZE_MAX /size ?
> 
> Whether or not size being 0 makes for a sane user is another question.
> The guideline is that size is the known constant from sizeof() or
> whatever and n is the variable number to allocate.
> 
> But yes, that inline is what I want :)

I will think about this. Maybe it will help to simplify/unify some other
users. Do you have any pointers to save me some grepping...?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
