Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5CF6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 00:55:15 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so31043026igb.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 21:55:15 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y10si4336079igf.95.2015.09.02.21.55.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 21:55:15 -0700 (PDT)
Date: Wed, 2 Sep 2015 21:55:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-Id: <20150902215512.9d0d62e74fa2f0a460a42af9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1509022152470.18064@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903023125.GC27804@redhat.com>
	<alpine.DEB.2.11.1509022152470.18064@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Heinz Mauelshagen <heinzm@redhat.com>, Viresh Kumar <viresh.kumar@linaro.org>, Dave Chinner <dchinner@redhat.com>, Joe Thornber <ejt@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alasdair G Kergon <agk@redhat.com>

On Wed, 2 Sep 2015 22:10:12 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> > But I'd still like some pointers/help on what makes slab merging so
> > beneficial.  I'm sure Christoph and others have justification.  But if
> > not then yes the default to slab merging probably should be revisited.
> 
> ...
>
> Check out the linux-mm archives for these dissussions.

Somewhat OT, but...  The question Mike asks should be comprehensively
answered right there in the switch-to-merging patch's changelog.

The fact that it is not answered in the appropriate place and that
we're reduced to vaguely waving at the list archives is a fail.  And a
lesson!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
