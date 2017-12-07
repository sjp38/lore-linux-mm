Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8290D6B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 07:07:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 96so3910305wrk.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 04:07:38 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id k184si3487244wmd.221.2017.12.07.04.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 04:07:36 -0800 (PST)
Date: Thu, 7 Dec 2017 13:07:35 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171207120735.GA24547@atrey.karlin.mff.cuni.cz>
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144219.22867-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129144219.22867-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

Hi!

> MAP_FIXED is used quite often to enforce mapping at the particular
> range. The main problem of this flag is, however, that it is inherently
> dangerous because it unmaps existing mappings covered by the requested
> range. This can cause silent memory corruptions. Some of them even with
> serious security implications. While the current semantic might be
> really desiderable in many cases there are others which would want to
> enforce the given range but rather see a failure than a silent memory
> corruption on a clashing range. Please note that there is no guarantee
> that a given range is obeyed by the mmap even when it is free - e.g.
> arch specific code is allowed to apply an alignment.
> 
> Introduce a new MAP_FIXED_SAFE flag for mmap to achieve this behavior.
> It has the same semantic as MAP_FIXED wrt. the given address request

Could we get some better name? Functionality seems reasonable, but
_SAFE suffix does not really explain what is going on to the user.

MAP_ADD_FIXED ?

								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
