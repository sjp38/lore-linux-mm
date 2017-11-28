Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C851D6B02BB
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:13:02 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u3so31256558pgn.11
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:13:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si24417038pgn.105.2017.11.28.00.13.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 00:13:01 -0800 (PST)
Date: Tue, 28 Nov 2017 09:12:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171128081259.gnkiw5227dtmfm4l@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <CAM43=SPVvBTPz31Uu=iz3fpS9tb75uSmL=pYP3AfsfmYr9u4Og@mail.gmail.com>
 <20171127195207.vderbbkbgygawuhx@dhcp22.suse.cz>
 <b6faf739-1a4a-12e1-ad84-0b42166d68c1@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6faf739-1a4a-12e1-ad84-0b42166d68c1@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon 27-11-17 15:26:27, John Hubbard wrote:
[...]
> Let me add a belated report, then: we ran into this limit while implementing 
> an early version of Unified Memory[1], back in 2013. The implementation
> at the time depended on tracking that assumed "one allocation == one vma".

And you tried hard to make those VMAs really separate? E.g. with
prot_none gaps?

> So, with only 64K vmas, we quickly ran out, and changed the design to work
> around that. (And later, the design was *completely* changed to use a separate
> tracking system altogether). 
> 
> The existing limit seems rather too low, at least from my perspective. Maybe
> it would be better, if expressed as a function of RAM size?

Dunno. Whenever we tried to do RAM scaling it turned out a bad idea
after years when memory grown much more than the code author expected.
Just look how we scaled hash table sizes... But maybe you can come up
with something clever. In any case tuning this from the userspace is a
trivial thing to do and I am somehow skeptical that any early boot code
would trip over the limit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
