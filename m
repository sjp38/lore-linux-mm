Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 6309D6B005A
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:44:32 -0500 (EST)
Date: Thu, 19 Jan 2012 14:44:25 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND, PATCH 4/6] memcg: fix broken boolean expression
Message-ID: <20120119134425.GQ24386@cmpxchg.org>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
 <1325883472-5614-4-git-send-email-kirill@shutemov.name>
 <20120109140404.GG3588@cmpxchg.org>
 <20120116115416.GA25687@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120116115416.GA25687@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, stable@kernel.org

On Mon, Jan 16, 2012 at 01:54:16PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 09, 2012 at 03:04:04PM +0100, Johannes Weiner wrote:
> > On Fri, Jan 06, 2012 at 10:57:50PM +0200, Kirill A. Shutemov wrote:
> > > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > 
> > > action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > > Cc: <stable@kernel.org>
> > 
> > I think you don't need to actually CC stable via email.  If you
> > include that tag, they will pick it up once the patch hits mainline.
> 
> I don't think it's a problem for stable@.
> 
> > 
> > The changelog is too terse, doubly so for a patch that should go into
> > stable.  How is the code supposed to work?  What are the consequences
> > of the bug?
> 
> Is it enough?

I think so, thank you.

> >From fe1c2f2dc1abf63cce12017e2d9031cf67f0a161 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> Date: Sat, 24 Dec 2011 04:12:53 +0200
> Subject: [PATCH 4/6] memcg: fix broken boolean expression
> 
> action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> 
> We should return at the point if CPU doesn't go away. Otherwise drain
> all counters and stocks from the CPU.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: <stable@kernel.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

But without the stable Cc, I guess :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
