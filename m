Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 6831F6B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 04:26:28 -0400 (EDT)
Date: Tue, 18 Jun 2013 10:26:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618082626.GE13677@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618081931.GB13677@dhcp22.suse.cz>
 <20130618082132.GC20528@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618082132.GC20528@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 18-06-13 12:21:33, Glauber Costa wrote:
> On Tue, Jun 18, 2013 at 10:19:31AM +0200, Michal Hocko wrote:
[...]
> > No this is ext3. But I can try to test with xfs as well if it helps.
> > [...]
> 
> XFS won't help this, on the contrary. The reason I asked is because XFS
> uses list_lru for its internal structures as well. So it is actually preferred
> if you are reproducing this without it, so we can at least isolate that part.

OK

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
