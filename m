Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id F17AC82F66
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 14:14:00 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so72623616lbb.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 11:14:00 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k78si16926914lfb.206.2015.12.07.11.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 11:13:59 -0800 (PST)
Date: Mon, 7 Dec 2015 14:13:46 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151207191346.GA3872@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151207134812.GA20782@dhcp22.suse.cz>
 <20151207164831.GA7256@cmpxchg.org>
 <5665CB78.7000106@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5665CB78.7000106@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Gordon <david.s.gordon@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>

On Mon, Dec 07, 2015 at 06:10:00PM +0000, Dave Gordon wrote:
> Exporting random uncontrolled variables from the kernel to loaded modules is
> not really considered best practice. It would be preferable to provide an
> accessor function - which is just what the declaration says we have; the
> implementation as a static inline (and/or macro) is what causes the problem
> here.

No, what causes the problem is thinking we can't trust in-kernel code.
If somebody screws up, we can fix it easily enough. Sure, we shouldn't
be laying traps and create easy-to-misuse interfaces, but that's not
what's happening here. There is no reason to add function overhead to
what should be a single 'mov' instruction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
