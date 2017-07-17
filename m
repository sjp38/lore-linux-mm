Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 645FE6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 05:11:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h64so71531571iod.9
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:11:51 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id q205si12759680iod.82.2017.07.17.02.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 02:11:50 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id z62so7010094ioi.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:11:50 -0700 (PDT)
Message-ID: <1500282655.8256.7.camel@gmail.com>
Subject: Re: [PATCH 4/6] mm/memcontrol: allow to uncharge page without using
 page->lru field
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 17 Jul 2017 19:10:55 +1000
In-Reply-To: <20170713211532.970-5-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
	 <20170713211532.970-5-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Thu, 2017-07-13 at 17:15 -0400, JA(C)rA'me Glisse wrote:
> HMM pages (private or public device pages) are ZONE_DEVICE page and
> thus you can not use page->lru fields of those pages. This patch
> re-arrange the uncharge to allow single page to be uncharge without
> modifying the lru field of the struct page.
> 
> There is no change to memcontrol logic, it is the same as it was
> before this patch.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
