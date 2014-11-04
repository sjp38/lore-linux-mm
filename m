Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9C26B009F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 11:34:14 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id g10so13837006pdj.24
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 08:34:13 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id ew5si537007pdb.254.2014.11.04.08.34.12
        for <linux-mm@kvack.org>;
        Tue, 04 Nov 2014 08:34:12 -0800 (PST)
Date: Tue, 04 Nov 2014 11:34:09 -0500 (EST)
Message-Id: <20141104.113409.1013929072623558759.davem@davemloft.net>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct
 page
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141104140937.GA18602@phnom.home.cmpxchg.org>
References: <20141104132701.GA18441@phnom.home.cmpxchg.org>
	<20141104134110.GD22207@dhcp22.suse.cz>
	<20141104140937.GA18602@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 4 Nov 2014 09:09:37 -0500

> You either need cgroup memory accounting and limiting or not.  There
> is no possible trade-off to be had.

I couldn't have said it better myself, +1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
