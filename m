Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC2F6B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 07:34:35 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fz6so8154070pac.31
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 04:34:35 -0700 (PDT)
Message-ID: <52398FBF.5060102@t-online.de>
Date: Wed, 18 Sep 2013 13:34:23 +0200
From: Knut Petersen <Knut_Petersen@t-online.de>
MIME-Version: 1.0
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch> <5239829F.4080601@t-online.de> <20130918105631.GS32145@phenom.ffwll.local>
In-Reply-To: <20130918105631.GS32145@phenom.ffwll.local>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


> Looking at the patch which introduced these error message for you, which
> changed the ->count_objects return value from 0 to SHRINK_STOP your patch
> below to treat 0 and SHRINK_STOP equally simply reverts the functional
> change.

Yes, for i915* it de facto restores the old behaviour.

> I don't think that's the intention behind SHRINK_STOP. But if it's the
> right think to do we better revert the offending commit directly.
But there is other code that also returns SHRINK_STOP. So i believe it's better to
adapt shrink_slab_node() to handle SHRINK_STOP properly than to revert 81e49f.

>   And since I lack clue I think that's a call for core mm guys to make.

I agree. They'll probably have to apply some additional changes to
shrink_slab_node(). It really doesn't look right to me, but they certainly
know better what the code is supposed to do ;-)


cu,
  Knut

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
