Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41AC76B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 14:23:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s73so195513240pfs.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 11:23:40 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id a2si9053158paf.153.2016.05.30.11.23.39
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 11:23:39 -0700 (PDT)
Date: Mon, 30 May 2016 11:23:35 -0700 (PDT)
Message-Id: <20160530.112335.1376503927443399332.davem@davemloft.net>
Subject: Re: [PATCH 12/17] sparc: get rid of superfluous __GFP_REPEAT
From: David Miller <davem@davemloft.net>
In-Reply-To: <1464599699-30131-13-git-send-email-mhocko@kernel.org>
References: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
	<1464599699-30131-13-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 30 May 2016 11:14:54 +0200

> From: Michal Hocko <mhocko@suse.com>
> 
> __GFP_REPEAT has a rather weak semantic but since it has been introduced
> around 2.6.12 it has been ignored for low order allocations.
> 
> {pud,pmd}_alloc_one is using __GFP_REPEAT but it always allocates from
> pgtable_cache which is initialzed to PAGE_SIZE objects. This means that
> this flag has never been actually useful here because it has always been
> used only for PAGE_ALLOC_COSTLY requests.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-arch@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
