Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 7A45D6B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 04:28:21 -0400 (EDT)
Date: Wed, 12 Jun 2013 10:28:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130612082817.GA6706@dhcp22.suse.cz>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
 <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1306052058340.25115@chino.kir.corp.google.com>
 <20130606053315.GB9406@cmpxchg.org>
 <20130606173355.GB27226@cmpxchg.org>
 <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
 <20130606215425.GM15721@cmpxchg.org>
 <alpine.DEB.2.02.1306061507330.15503@chino.kir.corp.google.com>
 <20130607000222.GT15576@cmpxchg.org>
 <alpine.DEB.2.02.1306111454030.4803@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306111454030.4803@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 11-06-13 14:57:08, David Rientjes wrote:
[...]
> > > > > > Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> 
> Ok, so the key here is that azurIt was able to reliably reproduce this 
> issue and now it has been resurrected after seven months of silence since 
> that thread.  I also notice that azurIt isn't cc'd on this thread.  Do we 
> know if this is still a problem?

I have backported the patch for his 3.2 and waiting for his feedback.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
