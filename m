Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 274F16B0037
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 07:01:38 -0400 (EDT)
Date: Mon, 18 Mar 2013 12:01:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Support 2M page allocations
 for ballooning
Message-ID: <20130318110136.GH10192@dhcp22.suse.cz>
References: <1363470088-24565-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-1-git-send-email-kys@microsoft.com>
 <1363470125-24606-2-git-send-email-kys@microsoft.com>
 <20130318105257.GG10192@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130318105257.GG10192@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, hannes@cmpxchg.org, yinghan@google.com

On Mon 18-03-13 11:52:57, Michal Hocko wrote:
> On Sat 16-03-13 14:42:05, K. Y. Srinivasan wrote:
> > While ballooning memory out of the guest, attempt 2M allocations first.
> > If 2M allocations fail, then go for 4K allocations. In cases where we
> > have performed 2M allocations, split this 2M page so that we can free this
> > page at 4K granularity (when the host returns the memory).
> 
> Maybe I am missing something but what is the advantage of 2M allocation
> when you split it up immediately so you are not using it as a huge page?

OK, it seems that Patch 1/2 says some advantages. That description
should be part of this patch IMO.
You are saying that a) it reduces fragmentation on the host b) it makes
ballooning more effective.

Have you measured any effects on the ability to allocate huge pages on
the host? What prevents from depleting high order pages on the host with
many guests? Also have you measured any effect on THP allocation success
rate on the host?

Could you clarify how this helps ballooning when you split the page
right after you allocate it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
