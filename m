Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 0A0206B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:57:18 -0400 (EDT)
Date: Wed, 19 Jun 2013 15:57:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130619135716.GA21014@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619073526.GB1990@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130619073526.GB1990@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-06-13 11:35:27, Glauber Costa wrote:
[...]
> Sorry if you said that before Michal.
> 
> But given the backtrace, are you sure this is LRU-related?

No idea. I just know that my mm tree behaves correctly after the whole
series has been reverted (58f6e0c8fb37e8e37d5ac17a61a53ac236c15047) and
before the latest version of the patchset has been applied.

> You mentioned you bisected it but found nothing conclusive.

Yes, but I was interested in crashes and not hangs so I will try it
again.

I really hope this is not just some stupidness in my tree.

> I will keep looking but maybe this could benefit from
> a broader fs look
> 
> In any case, the patch we suggested is obviously correct and we should
> apply nevertheless.  I will write it down and send it to Andrew.

OK, feel free to stick my Tested-by there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
