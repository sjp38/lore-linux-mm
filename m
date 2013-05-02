Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6F1116B025F
	for <linux-mm@kvack.org>; Thu,  2 May 2013 12:01:16 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z8so378677daj.3
        for <linux-mm@kvack.org>; Thu, 02 May 2013 09:01:15 -0700 (PDT)
Date: Thu, 2 May 2013 09:01:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add anon_hugepage stat
In-Reply-To: <20130502141709.GM1950@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1305020900470.7224@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com> <20130426111739.GF31157@dhcp22.suse.cz> <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com> <20130502141709.GM1950@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 2 May 2013, Michal Hocko wrote:

> I am not sure I understand. I assume you want to export the anon counter
> as well, right? Wouldn't that be too confusing? Yes, rss is a terrible
> name and mixing it with swapcache is arguably a good idea but are there
> any cases where you want anon - swapcache?
> 

This concept was obsoleted by 
mm-memcg-add-rss_huge-stat-to-memorystat.patch.  Thanks for the ack!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
