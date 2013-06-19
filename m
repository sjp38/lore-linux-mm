Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 20D746B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 10:02:40 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so4778746lbh.35
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 07:02:38 -0700 (PDT)
Date: Wed, 19 Jun 2013 18:02:34 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130619140234.GB4031@localhost.localdomain>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619073526.GB1990@localhost.localdomain>
 <20130619135716.GA21014@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130619135716.GA21014@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 19, 2013 at 03:57:16PM +0200, Michal Hocko wrote:
> On Wed 19-06-13 11:35:27, Glauber Costa wrote:
> [...]
> > Sorry if you said that before Michal.
> > 
> > But given the backtrace, are you sure this is LRU-related?
> 
> No idea. I just know that my mm tree behaves correctly after the whole
> series has been reverted (58f6e0c8fb37e8e37d5ac17a61a53ac236c15047) and
> before the latest version of the patchset has been applied.
> 
> > You mentioned you bisected it but found nothing conclusive.
> 
> Yes, but I was interested in crashes and not hangs so I will try it
> again.
> 
> I really hope this is not just some stupidness in my tree.
> 
Okay. Just looking at the stack trace you provided me it would be hard
to implicate us. But it is not totally unreasonable either since we touch
things around this. I would right now assign more probability to a tricky
bug than to some misconfiguration on your side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
