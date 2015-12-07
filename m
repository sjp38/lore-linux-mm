Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE0582F65
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 13:02:46 -0500 (EST)
Received: by wmec201 with SMTP id c201so177928520wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 10:02:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i129si25201430wma.2.2015.12.07.10.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 10:02:44 -0800 (PST)
Date: Mon, 7 Dec 2015 13:02:25 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151207180225.GA7826@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz>
 <20151207164831.GA7256@cmpxchg.org>
 <20151207170434.GD20774@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151207170434.GD20774@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, linux-mm@kvack.org

On Mon, Dec 07, 2015 at 06:04:35PM +0100, Michal Hocko wrote:
> Yes but the counter is an internal thing to the MM and the outside code
> should have no business in manipulating it directly.

The counter has been global scope forever. If you want to encapsulate
it, send a patch yourself and make your case in the changelog.  There
is no reason to make people with reasonable working code jump through
your personal preference hoops that have little to do with what their
patch is pursuing.

That being said, I'd NAK any patch that would turn a trivial accessor
like this into a full-blown function. Our interfaces encapsulate for
convenience, not out of distrust and bad faith.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
