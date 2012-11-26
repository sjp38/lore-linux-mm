Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E5DAC6B0075
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 15:53:59 -0500 (EST)
Date: Mon, 26 Nov 2012 15:53:49 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121126205349.GE2301@cmpxchg.org>
References: <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126174622.GE2799@cmpxchg.org>
 <20121126180444.GA12602@dhcp22.suse.cz>
 <20121126182421.GB2301@cmpxchg.org>
 <20121126190329.GB12602@dhcp22.suse.cz>
 <20121126192941.GC2301@cmpxchg.org>
 <20121126200848.GC12602@dhcp22.suse.cz>
 <20121126201918.GD2301@cmpxchg.org>
 <20121126214638.64723F01@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126214638.64723F01@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Nov 26, 2012 at 09:46:38PM +0100, azurIt wrote:
> >This issue has been around for a while so frankly I don't think it's
> >urgent enough to rush things.
> 
> 
> Well, it's quite urgent at least for us :( i wasn't reported this so
> far cos i wasn't sure it's a kernel thing. I will be really happy
> and thankfull if fix for this can go to 3.2 in some near
> future.. Thank you very much!

I understand and of course it's important that we get it fixed as soon
as possible.  All I meant was that this problem has not exactly been
introduced in 3.7 and the fix is non-trivial so we should not be
rushing a change like this into 3.7 just days before its release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
