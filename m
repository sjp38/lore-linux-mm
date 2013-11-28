Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8B66B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 06:55:01 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y10so742768wgg.2
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:55:01 -0800 (PST)
Received: from mail-ea0-x236.google.com (mail-ea0-x236.google.com [2a00:1450:4013:c01::236])
        by mx.google.com with ESMTPS id mx2si11122951wic.10.2013.11.28.03.55.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 03:55:00 -0800 (PST)
Received: by mail-ea0-f182.google.com with SMTP id o10so7562965eaj.13
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:55:00 -0800 (PST)
Date: Thu, 28 Nov 2013 12:54:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131128115458.GK2761@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com>
 <20131120152251.GA18809@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-11-13 19:33:00, David Rientjes wrote:
[...]
> Agreed, and I think the big downside of doing it with the loadable module 
> suggestion is that you can't implement such a wide variety of different 
> policies in modules.  Each of our users who own a memcg tree on our 
> systems may want to have their own policy and they can't load a module at 
> runtime or ship with the kernel.

But those users care about their local (memcg) OOM, don't they? So they
do not need any module and all they want is to get a notification.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
