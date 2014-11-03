Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA3B6B00FC
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 11:42:40 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id r10so11812913pdi.30
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 08:42:40 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id zm1si15585914pbc.201.2014.11.03.08.42.38
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 08:42:39 -0800 (PST)
Date: Mon, 03 Nov 2014 11:42:35 -0500 (EST)
Message-Id: <20141103.114235.2147567115691592307.davem@davemloft.net>
Subject: Re: [patch 1/3] mm: embed the memcg pointer directly into struct
 page
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141103150942.GA32052@phnom.home.cmpxchg.org>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
	<20141103080208.GA7052@js1304-P5Q-DELUXE>
	<20141103150942.GA32052@phnom.home.cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, tj@kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 3 Nov 2014 10:09:42 -0500

> Please re-introduce this code when your new usecase is ready to be
> upstreamed.  There is little reason to burden an unrelated feature
> with a sizable chunk of dead code for a vague future user.

+1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
