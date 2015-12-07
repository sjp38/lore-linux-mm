Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 351234402EE
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 11:48:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so158978866wme.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 08:48:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t185si24705475wmb.113.2015.12.07.08.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 08:48:51 -0800 (PST)
Date: Mon, 7 Dec 2015 11:48:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151207164831.GA7256@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151207134812.GA20782@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, linux-mm@kvack.org

On Mon, Dec 07, 2015 at 02:48:12PM +0100, Michal Hocko wrote:
> On Fri 04-12-15 15:58:53, Chris Wilson wrote:
> > Some modules, like i915.ko, use swappable objects and may try to swap
> > them out under memory pressure (via the shrinker). Before doing so, they
> > want to check using get_nr_swap_pages() to see if any swap space is
> > available as otherwise they will waste time purging the object from the
> > device without recovering any memory for the system. This requires the
> > nr_swap_pages counter to be exported to the modules.
> 
> I guess it should be sufficient to change get_nr_swap_pages into a real
> function and export it rather than giving the access to the counter
> directly?

What do you mean by "sufficient"? That is actually more work.

It should be sufficient to just export the counter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
