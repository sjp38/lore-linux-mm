Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id AC3236B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 06:57:10 -0400 (EDT)
Date: Tue, 21 Aug 2012 12:57:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 11/11] protect architectures where THREAD_SIZE >=
 PAGE_SIZE against fork bombs
Message-ID: <20120821105704.GF19797@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-12-git-send-email-glommer@parallels.com>
 <20120821093513.GD19797@dhcp22.suse.cz>
 <5033579D.5000203@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5033579D.5000203@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue 21-08-12 13:40:45, Glauber Costa wrote:
> On 08/21/2012 01:35 PM, Michal Hocko wrote:
[...]
> > I am asking because this should trigger memcg-oom
> > but that one will usually pick up something else than the fork bomb
> > which would have a small memory footprint. But that needs to be handled
> > on the oom level obviously.
> > 
> Sure, but keep in mind that the main protection is against tasks *not*
> in this memcg.

Yes and that's is good step forward. I just wanted to mention that we
still have the problem inside the subhierarchy. The changelog was not
specific enough.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
