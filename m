Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9152E6B0033
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 08:44:29 -0400 (EDT)
Date: Tue, 2 Jul 2013 14:44:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130702124427.GG16815@dhcp22.suse.cz>
References: <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130702121947.GE14996@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 02-07-13 22:19:47, Dave Chinner wrote:
[...]
> Ok, so it's been leaked from a dispose list somehow. Thanks for the
> info, Michal, it's time to go look at the code....

OK, just in case we will need it, I am keeping the machine in this state
for now. So we still can play with crash and check all the juicy
internals.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
