Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 980AF6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 14:51:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so347594107pfg.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 11:51:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rc13si4211496pac.262.2016.08.02.11.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 11:51:48 -0700 (PDT)
Date: Tue, 2 Aug 2016 11:51:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] radix-tree: account nodes to memcg only if explicitly
 requested
Message-Id: <20160802115146.b431dbfcd54761d3a6abd930@linux-foundation.org>
In-Reply-To: <20160802124644.GL12403@dhcp22.suse.cz>
References: <1470057188-7864-1-git-send-email-vdavydov@virtuozzo.com>
	<20160802115111.GG12403@dhcp22.suse.cz>
	<20160802124220.GC13263@esperanza>
	<20160802124644.GL12403@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2 Aug 2016 14:46:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Maybe Andrew just want's to mark it for stable with
> Fixes: 58e698af4c63 ("radix-tree: account radix_tree_node to memory cgroup")
>  Cc: stable # 4.6

Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
