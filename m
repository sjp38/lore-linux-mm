Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 14C8E6B0044
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:54:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6083271pad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 17:54:39 -0700 (PDT)
Date: Mon, 15 Oct 2012 17:54:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] doc: describe memcg swappiness more precisely
 memory.swappiness==0
In-Reply-To: <20121015220725.GB11682@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.00.1210151754220.31712@chino.kir.corp.google.com>
References: <20121011085038.GA29295@dhcp22.suse.cz> <1349945859-1350-1-git-send-email-mhocko@suse.cz> <20121015220354.GA11682@dhcp22.suse.cz> <20121015220725.GB11682@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 16 Oct 2012, Michal Hocko wrote:

> And a follow up for memcg.swappiness documentation which is more
> specific about spwappiness==0 meaning.
> ---
> From 1bc3a94fea728107ed108edd42df464b908cd067 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 15 Oct 2012 11:43:56 +0200
> Subject: [PATCH] doc: describe memcg swappiness more precisely
> 
> since fe35004f (mm: avoid swapping out with swappiness==0) memcg reclaim
> stopped swapping out anon pages completely when 0 value is used.
> Although this is somehow expected it hasn't been done for a really long
> time this way and so it is probably better to be explicit about the
> effect. Moreover global reclaim swapps out even when swappiness is 0
> to prevent from OOM killer.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
