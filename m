Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 572C96B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 17:53:42 -0500 (EST)
Date: Wed, 7 Nov 2012 14:53:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] memcg: oom: fix totalpages calculation for
 memory.swappiness==0
Message-Id: <20121107145340.b45a387c.akpm@linux-foundation.org>
In-Reply-To: <20121107224640.GE26382@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
	<1349945859-1350-1-git-send-email-mhocko@suse.cz>
	<20121015220354.GA11682@dhcp22.suse.cz>
	<20121107141025.2ac62206.akpm@linux-foundation.org>
	<20121107224640.GE26382@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 7 Nov 2012 23:46:40 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> > Realistically, is anyone likely to hurt from this?
> 
> The primary motivation for the fix was a real report by a customer.

Describe it please and I'll copy it to the changelog.

So that Greg can understand why we sent this at him and so that others
who hit the same problem (or any other problem!) will be able to
determine whether this patch might solve it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
