Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5BA416B0034
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 07:13:44 -0400 (EDT)
Date: Mon, 9 Sep 2013 13:13:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: store memcg name for oom kill log consistency
Message-ID: <20130909111342.GA22212@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com>
 <20130829133032.GB12077@dhcp22.suse.cz>
 <20130905135219.GE13666@dhcp22.suse.cz>
 <alpine.DEB.2.02.1309090200110.1935@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309090200110.1935@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 09-09-13 02:00:26, David Rientjes wrote:
> On Thu, 5 Sep 2013, Michal Hocko wrote:
[...]
> > Reported-by: David Rientjes <rientjes@google.com>
> 
> Remove this.

OK. Is there any other way how to give you a credit for
discovering/reporting this issue?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
