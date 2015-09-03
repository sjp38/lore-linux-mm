Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD166B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 20:48:17 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so3053025igc.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 17:48:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e90si6283302ioj.33.2015.09.02.17.48.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 17:48:16 -0700 (PDT)
Date: Wed, 2 Sep 2015 17:48:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-Id: <20150902174815.199d51a480a01e9a754367e3@linux-foundation.org>
In-Reply-To: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Snitzer <snitzer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2 Sep 2015 16:13:44 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Sep 2, 2015 at 10:39 AM, Mike Snitzer <snitzer@redhat.com> wrote:
> >
> > - last but not least: add SLAB_NO_MERGE flag to mm/slab_common and
> >   disable slab merging for all of DM's slabs (XFS will also use
> >   SLAB_NO_MERGE once merged).
> 
> So I'm not at all convinced this is the right thing to do. In fact,
> I'm pretty convinced it shouldn't be done this way. Since those
> commits were at the top of your tree, I just didn't pull them, but
> took the rest..

I don't have problems with the patch itself, really.  It only affects
callers who use SLAB_NO_MERGE and those developers can make
their own decisions.

It is a bit sad to de-optimise dm for all users for all time in order
to make life a bit easier for dm's developers, but maybe that's a
decent tradeoff.


What I do have a problem with is that afaict the patch appeared on
linux-mm for the first time just yesterday.  Didn't cc slab developers,
it isn't in linux-next, didn't cc linux-kernel or linux-mm or slab/mm
developers on the pull request.  Bad!

I'd like the slab developers to have time to understand and review this
change, please.  Partly so they have a chance to provide feedback for
the usual reasons, but also to help them understand the effect their
design choice had on client subystems.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
