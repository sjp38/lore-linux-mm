Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 90DB66B026B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 12:04:38 -0500 (EST)
Received: by wmww144 with SMTP id w144so158767890wmw.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 09:04:38 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id y10si37510657wjw.208.2015.12.07.09.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 09:04:37 -0800 (PST)
Received: by wmec201 with SMTP id c201so175451735wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 09:04:37 -0800 (PST)
Date: Mon, 7 Dec 2015 18:04:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151207170434.GD20774@dhcp22.suse.cz>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz>
 <20151207164831.GA7256@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151207164831.GA7256@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, linux-mm@kvack.org

On Mon 07-12-15 11:48:31, Johannes Weiner wrote:
> On Mon, Dec 07, 2015 at 02:48:12PM +0100, Michal Hocko wrote:
> > On Fri 04-12-15 15:58:53, Chris Wilson wrote:
> > > Some modules, like i915.ko, use swappable objects and may try to swap
> > > them out under memory pressure (via the shrinker). Before doing so, they
> > > want to check using get_nr_swap_pages() to see if any swap space is
> > > available as otherwise they will waste time purging the object from the
> > > device without recovering any memory for the system. This requires the
> > > nr_swap_pages counter to be exported to the modules.
> > 
> > I guess it should be sufficient to change get_nr_swap_pages into a real
> > function and export it rather than giving the access to the counter
> > directly?
> 
> What do you mean by "sufficient"?

Sufficient for the functionality which is required.

> That is actually more work.

Yes marginally more work.

> It should be sufficient to just export the counter.

Yes but the counter is an internal thing to the MM and the outside code
should have no business in manipulating it directly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
