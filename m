Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id DF6726B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 06:22:27 -0500 (EST)
Received: by wmww144 with SMTP id w144so176942466wmw.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 03:22:27 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id j84si29861844wma.50.2015.12.08.03.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 03:22:26 -0800 (PST)
Received: by wmvv187 with SMTP id v187so208865548wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 03:22:26 -0800 (PST)
Date: Tue, 8 Dec 2015 12:22:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151208112225.GB25800@dhcp22.suse.cz>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz>
 <20151207164831.GA7256@cmpxchg.org>
 <5665CB78.7000106@intel.com>
 <20151207191346.GA3872@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151207191346.GA3872@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On Mon 07-12-15 14:13:46, Johannes Weiner wrote:
> On Mon, Dec 07, 2015 at 06:10:00PM +0000, Dave Gordon wrote:
> > Exporting random uncontrolled variables from the kernel to loaded modules is
> > not really considered best practice. It would be preferable to provide an
> > accessor function - which is just what the declaration says we have; the
> > implementation as a static inline (and/or macro) is what causes the problem
> > here.
> 
> No, what causes the problem is thinking we can't trust in-kernel code.

This is not about the trust. It is about a clear API and separation.

> If somebody screws up, we can fix it easily enough. Sure, we shouldn't
> be laying traps and create easy-to-misuse interfaces, but that's not
> what's happening here. There is no reason to add function overhead to
> what should be a single 'mov' instruction.

The mere fact that the current implementation is a simple atomic_long_read
is a detail and not important for the API. The function is not used
in any hot path where a single function call overhead would be a
performance killer. Exporting implementation details to random users
tends to add maintenance burden in future.

I think it is natural to export symbols which are consumed by modules
and that will be get_nr_swap_pages(). I do not even understand the
resistance against that. Anyway I am not going to argue about it more.
I have raised my review comment and leave the decision to Chris/Andrew.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
